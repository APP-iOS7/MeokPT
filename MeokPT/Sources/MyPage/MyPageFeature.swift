import ComposableArchitecture
import Foundation
import FirebaseAuth

// @Reducer
// struct Path {
//     @ObservableState
//     enum State: Equatable { /* ... */ }
//     enum Action { /* ... */ }
//     var body: some Reducer<State, Action> { /* ... */ }
// }

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State {
        var currentUser: User?
        var userProfile: UserProfile?
        
        @Presents var profileSettingModal: ProfileSettingFeature.State?
        var path = StackState<Path.State>()
    }
    
    enum Action {
        case onAppear
        case loginSignUpButtonTapped
        case profileEditButtonTapped
        case logoutButtonTapped
        case withDrawalButtonTapped
        
         case profileSettingModal(PresentationAction<ProfileSettingFeature.Action>)
        // case path(StackAction<Path.State, Path.Action>)

        case delegate(DelegateAction)
    }
    
     enum DelegateAction {
         case loginSignUpButtonTapped
         case profileSettingButtonTapped
         case requestLogout
         case requestWithdrawal
     }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .loginSignUpButtonTapped:
                return .send(.delegate(.loginSignUpButtonTapped))
                
            case .profileEditButtonTapped:
                return .send(.delegate(.profileSettingButtonTapped))

            case .logoutButtonTapped:
                return .send(.delegate(.requestLogout))
                
            case .withDrawalButtonTapped:
                return .send(.delegate(.requestWithdrawal))
                
            case .delegate(_):
                return .none
            
            case .profileSettingModal:
                return .none
            }
        }
         .ifLet(\.$profileSettingModal, action: \.profileSettingModal) { ProfileSettingFeature() }
//         .forEach(\.path, action: \.path) { Path() }
    }
}
