import ComposableArchitecture
import Foundation
import SwiftData

enum DietFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case favorites = "즐겨찾기"
    var id: String { self.rawValue }
}

@Reducer
struct DietFeature {
    @Reducer
    enum Path {
        case detail(DietDetailFeature)
    }
    
    @ObservableState
    struct State {
        
        var dietList: IdentifiedArrayOf<Diet> = []
        var searchText = ""
        var selectedFilter: DietFilter = .all
        
        var path = StackState<Path.State>()
        
        var filteredDiets: [Diet] {
            let searchedDiets = searchText.isEmpty ? dietList.elements : dietList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            switch selectedFilter {
            case .all:
                return searchedDiets
            case .favorites:
                return searchedDiets.filter { $0.isFavorite }
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case dietsLoaded([Diet])
        case addButtonTapped
        case dietCellTapped(id: UUID)
        case likeButtonTapped(id: UUID, isFavorite: Bool)
        case dietCreated(Diet)
        case navigateToNewDiet(UUID)
        
        case path(StackActionOf<Path>)
    }
    
    @Dependency(\.modelContainer) var modelContainer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            let descriptor = FetchDescriptor<Diet>(sortBy: [SortDescriptor(\.title)])
                            let diets = try context.fetch(descriptor)
                            send(.dietsLoaded(diets))
                        } catch {
                            print("Failed to fetch diets: \(error)")
                            send(.dietsLoaded([]))
                        }
                    }
                }
                
            case let .dietsLoaded(diets):
                state.dietList = IdentifiedArrayOf(uniqueElements: diets)
                return .none

            case .addButtonTapped:
                return .run { send in
                    await MainActor.run {
                        let context = modelContainer.mainContext
                        let newDiet = Diet(title: "새로운 식단", isFavorite: false, foods: [])
                        context.insert(newDiet)
                        
                        send(.dietCreated(newDiet))
                    }
                }

            case let .dietCreated(newDiet):
                state.dietList.append(newDiet)
                return .send(.navigateToNewDiet(newDiet.id))

            case let .navigateToNewDiet(dietID):
                guard let diet = state.dietList[id: dietID] else { return .none }
                let detailState = DietDetailFeature.State(
                    diet: diet,
                    dietID: dietID,
                    createDietFullScreenCover: CreateDietFeature.State()
                )
                state.path.append(.detail(detailState))
                return .none
                
            case let .dietCellTapped(id):
                if let diet = state.dietList[id: id] {
                    let detailState = DietDetailFeature.State(
                        diet: diet,
                        dietID: id,
                    )
                    state.path.append(.detail(detailState))
                }
                return .none
                
            case let .likeButtonTapped(id, isFavorite):
                if let dietToUpdate = state.dietList[id: id] {
                    dietToUpdate.isFavorite = isFavorite
                }
                return .none
                
            case .binding(_):
                return .none
                
            case let .path(.element(id: pathID, action: .detail(.delegate(.favoriteToggled(isFavorite))))):
                guard let dietDetailState = state.path[id: pathID]?.detail else {
                    return .none
                }
                return .send(.likeButtonTapped(id: dietDetailState.dietID, isFavorite: isFavorite))

            case let .path(.element(id: pathID, action: .detail(.delegate(.addFoodToDiet(foodName, amount, calories, carbohydrates, protein, fat, dietaryFiber, sugar, sodium))))):
                guard let dietDetailState = state.path[id: pathID]?.detail,
                      let dietToUpdate = state.dietList[id: dietDetailState.dietID] else {
                    return .none
                }
                
                // 새 음식 아이템 생성
                let newFood = Food(
                    name: foodName,
                    amount: amount,
                    kcal: calories,
                    carbohydrate: carbohydrates,
                    protein: protein,
                    fat: fat,
                    dietaryFiber: dietaryFiber,
                    sodium: sodium,
                    sugar: sugar
                )
                // 식단에 음식 추가
                dietToUpdate.foods.append(newFood)
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
