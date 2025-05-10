import ComposableArchitecture
import SwiftUI

enum AppRoute: Identifiable {
    case loginView
    case dietDetailView
    
    var id: Self { self }
    
    var screenType: String {
        switch self {
        case .loginView:
            return "fullScreenCover"
        case .dietDetailView:
            return "navigation"
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
        
        var appRoute: AppRoute?
        
        var path = NavigationPath()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dietAction(DietFeature.Action)
        case analyzeAction(AnalyzeFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
        case loginAction(LoginFeature.Action)
        case signUpAction(SignUpFeature.Action)
        
        case setActiveSheet(AppRoute?)
        case dismissSheet
        
        case push(AppRoute)
        case popToRoot
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()

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
            case .dietAction(.delegate(.goDietDetailView)):
                return .send(.push(.dietDetailView))
                
            case .myPageAction(.delegate(.loginSignUpButtonTapped)):
                return .send(.setActiveSheet(.loginView))
                
            case .loginAction(.delegate(.dismissLoginSheet)):
                return .send(.dismissSheet)
                
            case .setActiveSheet(let newSheet):
                state.appRoute = newSheet
                return .none
                
            case .dismissSheet:
                // appRoute 가 nil 이면 sheet 는 닫힌다.
                state.appRoute = nil
                return .none
                
            case .push(let route):
                state.path.append(route)
                return .none

            case .popToRoot:
                state.path.removeLast(state.path.count)
                return .none
                
            case .binding(_):
                return .none
            default:
                return .none
            }
        }
    }
}
