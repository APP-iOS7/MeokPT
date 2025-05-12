import ComposableArchitecture
import Foundation

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State {
        
    }
    
    enum Action {
        case onAppear
        case loginSignUpButtonTapped
        case delegate(DelegateAction)
    }
    
     enum DelegateAction {
         case loginSignUpButtonTapped
     }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .loginSignUpButtonTapped:
                return .send(.delegate(.loginSignUpButtonTapped))
            case .delegate(_):
                return .none
            }
        }
    }
}
