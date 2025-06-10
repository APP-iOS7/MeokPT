import ComposableArchitecture
import SwiftData
import Foundation

struct DietSelectionSheetFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var diets: IdentifiedArrayOf<Diet> = []
        
        var filteredDiets: IdentifiedArrayOf<Diet> {
            switch currentFilter {
            case .all:
                return diets
            case .favorite:
                return diets.filter { $0.isFavorite }
            }
        }

        var selectedDiets: Set<Diet.ID> = []
        var currentFilter: Options = .all

        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    @CasePathable
    enum Action: Equatable {
        case loadDiets
        
        case _internalDietsLoadComplted([Diet])
        case _internalDietsLoadFailed(DataFetchError)
        
        case addDietButtonTapped
        case delegate(Delegate)
        
        case setFilter(Options)
        case toggleDietSelection(Diet.ID)
        
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

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
            let selected = state.diets.filter { state.selectedDiets.contains($0.id) }
            return .run { send in
                await MainActor.run {
                    let context = modelContainer.mainContext

                    for diet in selected {
                        let dietItem = DietItem.fromDiet(diet)
                        context.insert(dietItem)
                    }
                    
                    do {
                        try context.save()
                    } catch {
                        print("DietItem 저장 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    do {
                        let allDietItems = try context.fetch(FetchDescriptor<DietItem>())
                        
                        for type in NutritionType.allCases {
                            let totalValue: Double = allDietItems
                                .compactMap { $0.nutrientValue(for: type) }
                                .reduce(0, +)
                            
                            let roundedValue = Int(totalValue.rounded())
                            let raw = type.rawValue
                            
                            let descriptor = FetchDescriptor<NutritionItem>(
                                predicate: #Predicate { $0.typeRawValue == raw }
                            )
                            
                            if let existing = try context.fetch(descriptor).first {
                                existing.value = roundedValue
                            } else {
                                let newItem = NutritionItem(
                                    type: type,
                                    value: roundedValue,
                                    max: 0
                                )
                                context.insert(newItem)
                            }
                        }
                        try context.save()
                        send(.delegate(.dietSelected(Array(selected))))
                    } catch {
                        print("NuritionItem 업데이트 실패")
                    }
                }
            }
        case .delegate:
            return .none
        
        case let .setFilter(option):
            state.currentFilter = option
            return .none
            
        case let .toggleDietSelection(id):
            if state.selectedDiets.contains(id) {
                state.selectedDiets.remove(id)
            } else {
                state.selectedDiets.insert(id)
            }
            return .none

        }
    }
}
