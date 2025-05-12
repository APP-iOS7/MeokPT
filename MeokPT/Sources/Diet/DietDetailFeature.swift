import ComposableArchitecture
import Foundation

struct Food: Identifiable, Equatable {
    let name: String
    var amount: Double
    var kcal: Double
    var carbohydrate: Double
    var protein: Double
    var fat: Double
    let id: UUID = UUID()
}

@Reducer
struct DietDetailFeature {
    @ObservableState
    struct State: Equatable {
        var diet: Diet
        var foods: [Food]
    }
    
    enum Action {
        case likeButtonTapped
        case updateTitle(String)
        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case favoriteToggled(isFavorite: Bool)
    }
    
    enum CancelID { case timer }
    
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
