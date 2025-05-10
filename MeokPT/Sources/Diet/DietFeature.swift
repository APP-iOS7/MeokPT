import ComposableArchitecture
import Foundation

@Reducer
struct DietFeature {
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case onAppear
        case goDietDetailViewAction
        case delegate(DelegateAction)
    }
    
    enum DelegateAction {
        case goDietDetailView
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .goDietDetailViewAction:
                return .send(.delegate(.goDietDetailView))
            case .delegate(_):
                return .none
            }
        }
    }
}
