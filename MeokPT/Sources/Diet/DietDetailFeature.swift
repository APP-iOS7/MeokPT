import ComposableArchitecture
import Foundation

@Reducer
struct DietDetailFeature {
    @ObservableState
    struct State: Equatable, Hashable {
        var diet: Diet
        let dietID: UUID
    }
    
    enum Action {
        case likeButtonTapped
        case updateTitle(String)
        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case favoriteToggled(isFavorite: Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .likeButtonTapped:
                state.diet.isFavorite.toggle()
                return .send(.delegate(.favoriteToggled(isFavorite: state.diet.isFavorite)))
            case let .updateTitle(newTitle):
                state.diet.title = newTitle
                return .none
            case .delegate:
                return .none
            }
        }
    }
}
