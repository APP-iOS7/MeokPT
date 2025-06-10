import ComposableArchitecture
import SwiftData
import Foundation

struct DietSelectionSheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var diets: IdentifiedArrayOf<Diet> = []
        
        var filteredDiets: IdentifiedArrayOf<Diet> {
            let searchedDiets = searchText.isEmpty ? diets.elements : diets.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            let favoriteFilteredDiets = isFavoriteFilterActive ? searchedDiets.filter { $0.isFavorite } : searchedDiets
            
            switch selectedFilter {
            case .dateDescending:
                return IdentifiedArrayOf(uniqueElements: favoriteFilteredDiets.sorted { $0.creationDate > $1.creationDate })
            case .nameAscending:
                return IdentifiedArrayOf(uniqueElements: favoriteFilteredDiets.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
            }
        }

        var selectedDiets: Set<Diet.ID> = []
        var selectedFilter: DietFilter = .dateDescending 
        var isFavoriteFilterActive: Bool = false
        var searchText: String = ""

        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    @CasePathable
    enum Action: Equatable, BindableAction {
        case loadDiets
        
        case _internalDietsLoadComplted([Diet])
        case _internalDietsLoadFailed(DataFetchError)
        
        case addDietButtonTapped
        case delegate(Delegate)
        
        case favoriteFilterButtonTapped
        case toggleDietSelection(Diet.ID)
        case binding(BindingAction<State>)
        
        enum Delegate: Equatable {
            case dietSelected([Diet])
        }
    }
    
    enum DataFetchError: Error, Equatable {
        case dietFetchFailed
        case fetchFailed
    }
    
    enum DietError: Error, Equatable {
        case fetchFailed(String)
        
        static func == (lhs: DietError, rhs: DietError) -> Bool {
            switch (lhs, rhs) {
            case let (.fetchFailed(lhsMessage), .fetchFailed(rhsMessage)):
                return lhsMessage == rhsMessage
            }
        }
        
        var localizedDescription: String {
            switch self {
            case .fetchFailed(let msg): return msg
            }
        }
    }

    @Dependency(\.modelContainer) var modelContainer

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loadDiets:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            let descriptor = FetchDescriptor<Diet>()
                            let items = try context.fetch(descriptor)
                            
                            send(._internalDietsLoadComplted(items))
                        } catch {
                            send(._internalDietsLoadFailed(.fetchFailed))
                        }
                    }
                }
            case let ._internalDietsLoadComplted(items):
                state.isLoading = false
                state.diets = IdentifiedArrayOf(uniqueElements: items)
                print("Diets 로딩 성공")
                
                return .none
                
            case let ._internalDietsLoadFailed(error):
                state.isLoading = false
                state.errorMessage = "Diets 정보 불러오기 실패"
                print("에러: \(error.localizedDescription)")
                
                return .none
                
            case .addDietButtonTapped:
                let selectedIDs = state.selectedDiets
                
                return .run { send in
                    await Task { @MainActor in
                        do {
                            let context = modelContainer.mainContext
                            let descriptor = FetchDescriptor<Diet>(
                                predicate: #Predicate { selectedIDs.contains($0.id) }
                            )

                            let selectedDiets = try context.fetch(descriptor)

                            for diet in selectedDiets {
                                let dietItem = DietItem.fromDiet(diet)
                                context.insert(dietItem)
                                
                                for type in NutritionType.allCases {
                                    let amountToAdd = dietItem.nutrientValue(for: type)
                                    let raw = type.rawValue
                                    
                                    let nutritionDescriptor = FetchDescriptor<NutritionItem>(
                                        predicate: #Predicate { $0.typeRawValue == raw }
                                    )
                                    
                                    if let existing = try context.fetch(nutritionDescriptor).first {
                                        existing.value += Int(amountToAdd ?? 0)
                                    } else {
                                        let newItem = NutritionItem(type: type, value: Int(amountToAdd ?? 0), max: 0)
                                        context.insert(newItem)
                                    }
                                }
                            }

                            try context.save()
                            
                            send(.delegate(.dietSelected(selectedDiets)))
                            
                        } catch {
                            print("DietItem 저장 또는 조회 실패: \(error.localizedDescription)")
                        }
                    }.value
                }
                
            case .delegate:
                return .none
            
            case .favoriteFilterButtonTapped:
                state.isFavoriteFilterActive.toggle()
                return .none
            
            case let .toggleDietSelection(id):
                if state.selectedDiets.contains(id) {
                    state.selectedDiets.remove(id)
                } else {
                    state.selectedDiets.insert(id)
                }
                return .none

            case .binding:
                return .none
            }
        }
    }
}
