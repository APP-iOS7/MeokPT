import ComposableArchitecture
import SwiftUI

enum AppRoute: Identifiable {
    case loginView
    case dietDetailView
    case dietSelectionModalView
    case AIModalView
    
    var id: Self { self }
    
    var screenType: String {
        switch self {
        case .loginView:
            return "fullScreenCover"
        case .dietDetailView:
            return "navigation"
        case .dietSelectionModalView:
            return "fullScreenCover"
        case .AIModalView:
            return "sheet"
        }
    }
}

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State {
        var dietState = DietFeature.State()
        var analyzeState = DailyNutritionDietInfoFeature.State()
        var communityState = CommunityFeature.State()
        var myPageState = MyPageFeature.State()
        var loginState = LoginFeature.State()
        var signUpState = SignUpFeature.State()
        var profileSettingState = ProfileSettingFeature.State()
        var dietDetailState = DietDetailFeature.State()
        var dietSelectionModalState = DietSelectionModalFeature.State()
        var AIModalState = AIModalFeature.State()
        
        var appRoute: AppRoute?
        
        var path = NavigationPath()
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dietAction(DietFeature.Action)
        case analyzeAction(DailyNutritionDietInfoFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
        case loginAction(LoginFeature.Action)
        case signUpAction(SignUpFeature.Action)
        case profileSettingAction(ProfileSettingFeature.Action)
        case dietDetailAction(DietDetailFeature.Action)
        case dietSelectionModalAction(DietSelectionModalFeature.Action)
        case AIModalAction(AIModalFeature.Action)
        
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
            DailyNutritionDietInfoFeature()
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
        
        Scope(state: \.profileSettingState, action: \.profileSettingAction) {
            ProfileSettingFeature()
        }
        
        Scope(state: \.dietDetailState, action: \.dietDetailAction) {
            DietDetailFeature()
        }
        
        Scope(state: \.dietSelectionModalState, action: \.dietSelectionModalAction) {
            DietSelectionModalFeature()
        }
        
        Scope(state: \.AIModalState, action: \.AIModalAction) {
            AIModalFeature()
        }
        
        Reduce { state, action in
            switch action {
                
            case let .analyzeAction(action):
                  switch action {
                  case .dietSelectionDelegate(.toDietSelectionModalView):
                      return .send(.setActiveSheet(.dietSelectionModalView))

                  case .AIModalDelegate(.toAIModalView):
                      return .send(.setActiveSheet(.AIModalView))

                  default:
                      return .none
                  }
                
            case .myPageAction(.delegate(.loginSignUpButtonTapped)):
                return .send(.setActiveSheet(.loginView))
                
            case .loginAction(.delegate(.dismissLoginSheet)):
                return .send(.dismissSheet)
                
            case .setActiveSheet(let newSheet):
                state.appRoute = newSheet
                return .none
                
            case .dismissSheet:
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
