import ComposableArchitecture
import SwiftUI

enum ActiveSheet: Hashable, Identifiable {
    case login
    case signUp
    
    var id: Self { self }
    
    var isFullScreen: Bool {
        // true  -> fullScreenCover
        // false -> sheet
        switch self {
        case .login:
            return true
        case .signUp:
            return false
        }
    }
}

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State {
        var dietState = DietFeature.State()
        var analyzeState = AnalyzeFeature.State()
        var communityState = CommunityFeature.State()
        var myPageState = MyPageFeature.State()
        var loginState = LoginFeature.State()
        var signUpState = SignUpFeature.State()
        
        var activeSheet: ActiveSheet?
    }
    
    enum Action {
        case dietAction(DietFeature.Action)
        case analyzeAction(AnalyzeFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
        case loginAction(LoginFeature.Action)
        case signUpAction(SignUpFeature.Action)
        
        case dismissSheet
        case setActiveSheet(ActiveSheet?)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.dietState, action: \.dietAction) {
            DietFeature()
        }
        
        Scope(state: \.analyzeState, action: \.analyzeAction) {
            AnalyzeFeature()
        }
        
        Scope(state: \.communityState, action: \.communityAction) {
            CommunityFeature()
        }
        
        Scope(state: \.myPageState, action: \.myPageAction) {
            MyPageFeature()
        }
        
        Scope(state: \.loginState, action: \.loginAction) {
            LoginFeature()
        }
        
        Scope(state: \.signUpState, action: \.signUpAction) {
            SignUpFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .myPageAction(.delegate(.loginSignUpButtonTapped)):
                state.activeSheet = .login
                return .none
                
            case .loginAction(.delegate(.dismiss)):
                return .send(.dismissSheet)
                
            case .setActiveSheet(let newSheet):
                state.activeSheet = newSheet
                return .none
                
            case .dismissSheet:
                state.activeSheet = nil
                return .none
                
            default:
                return .none
            }
        }
    }
}
