import ComposableArchitecture
import Foundation

@Reducer
struct DietDetailFeature {
    @ObservableState
    struct State: Equatable {
        var diet: Diet
        let dietID: UUID
        
        @Presents var createDietFullScreenCover: CreateDietFeature.State?
    }
    
    enum Action {
        case likeButtonTapped
        case updateTitle(String)
        case addFoodButtonTapped
        case createDietFullScreenCover(PresentationAction<CreateDietFeature.Action>)
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
            case .addFoodButtonTapped:
                state.createDietFullScreenCover = CreateDietFeature.State()
                return .none
            case .createDietFullScreenCover(.presented(.delegate(.dismissSheet))):
                state.createDietFullScreenCover = nil
                return .none
            case .createDietFullScreenCover(_):
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$createDietFullScreenCover, action: \.createDietFullScreenCover) {
            CreateDietFeature()
        }
    }
}
