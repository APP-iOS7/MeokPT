import ComposableArchitecture
import Foundation

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
        case addButtonTapped
        case dietCellTapped(id: Diet.ID)
        case likeButtonTapped(id: Diet.ID, isFavorite: Bool)
        
        case path(StackActionOf<Path>)

    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                let newDiet = Diet(title: "새로운 식단", isFavorite: false, foods: [])
                state.dietList.append(newDiet)
                
                // DetailView -> CreateDietView 열기
                let detailState = DietDetailFeature.State(
                    diet: newDiet,
                    dietID: newDiet.id,
                    createDietFullScreenCover: CreateDietFeature.State()
                )
                state.path.append(.detail(detailState))
                return .none
                
            case let .dietCellTapped(id):
                if let diet = state.dietList.first(where: { $0.id == id }) {
                    state.path.append(.detail(DietDetailFeature.State(diet: diet, dietID: id)))
                }
                return .none
                
            case let .likeButtonTapped(id, isFavorite):
                guard var dietToUpdate = state.dietList[id: id] else {
                    return .none
                }
                if dietToUpdate.isFavorite != isFavorite {
                    dietToUpdate.isFavorite = isFavorite
                    state.dietList[id: id] = dietToUpdate
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
                      var dietToUpdate = state.dietList[id: dietDetailState.dietID] else {
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
                state.dietList[id: dietDetailState.dietID] = dietToUpdate
                
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
