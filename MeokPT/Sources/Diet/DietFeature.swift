import ComposableArchitecture
import Foundation

@Reducer
struct DietFeature {
    @ObservableState
    struct State: Equatable {
        var dietList: IdentifiedArrayOf<Diet> = []
        var path = StackState<DietDetailFeature.State>()
    }
    
    enum Action {
        case likeButtonTapped(id: Diet.ID)
        case path(StackAction<DietDetailFeature.State, DietDetailFeature.Action>)
        case addButtonTapped
        case dietCellTapped(id: Diet.ID)
    }

//    @Reducer
//    struct Path {
//        @ObservableState
//        enum State: Equatable, Hashable {
//            case detail(DietDetailFeature.State)
//        }
//        enum Action {
//            case detail(DietDetailFeature.Action)
//        }
//        var body: some ReducerOf<Self> {
//            Scope(state: \.detail, action: \.detail) {
//                DietDetailFeature()
//            }
//        }
//    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .likeButtonTapped(id):
                guard state.dietList[id: id] != nil else { return .none }
                state.dietList[id: id]?.isFavorite.toggle()
                return .none

            case .addButtonTapped:
                let newDiet = Diet(title: "새로운 식단", isFavorite: false, foods: [])
                state.dietList.append(newDiet)
                state.path.append(DietDetailFeature.State(diet: newDiet))
                return .none
                
            case .dietCellTapped(let id):
                guard let diet = state.dietList[id: id] else { return .none }
                state.path.append(DietDetailFeature.State(diet: diet))
                return .none

//            case let .path(.element(id: pathID, action: .detail(.delegate(.favoriteToggled(isFavorite))))):
//                guard case let .detail(detailState) = state.path[id: pathID] else { return .none }
//                if state.dietList[id: detailState.diet.id] != nil {
//                    state.dietList[id: detailState.diet.id]?.isFavorite = isFavorite
//                }
//                return .none
            
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) { // Path Reducer 통합
            DietDetailFeature()
        }
    }
}
