import ComposableArchitecture
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum AppRoute: Identifiable {
    case loginView
    case profileSettingView
    case dietSelectionModalView
    case AIModalView
    
    var id: Self { self }
    
    var screenType: ScreenPresentationType {
        switch self {
        case .loginView:
            return .fullScreenCover
        case .profileSettingView:
            return .fullScreenCover
        }
    }
}

enum ScreenPresentationType {
    case sheet
    case fullScreenCover
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
        var profileSettingState = ProfileSettingFeature.State()
        var dietSelectionModalState = DietSelectionModalFeature.State()
        var AIModalState = AIModalFeature.State()
        
        var appRoute: AppRoute?
                
        var currentUser: User?
        var userProfile: UserProfile?
        var isLoadingUserProfile: Bool = false
        var userProfileError: String?
        var isInitialAuthCheckDone: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dietAction(DietFeature.Action)
        case analyzeAction(DailyNutritionDietInfoFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
        case loginAction(LoginFeature.Action)
        case profileSettingAction(ProfileSettingFeature.Action)
        case dietSelectionModalAction(DietSelectionModalFeature.Action)
        case AIModalAction(AIModalFeature.Action)
        
        case setActiveSheet(AppRoute?)
        case dismissSheet
                
        case authStatusChanged(User?)
        case handleAuthenticatedUser(User)
        case userProfileLoaded(Result<UserProfile, Error>)
        case navigateToProfileSetting
        case clearUserData
        case fetchUserProfile(String)
        
        case onAppear
    }

    enum CancelID {
        case userProfileFetch
        case authStateListener
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
                
            // MARK: - loginAction
            case .loginAction(.delegate(.dismissLoginSheet)):
                state.appRoute = nil
                return .none
                            
            case .loginAction(.delegate(.loginSuccessfully(let user))):
                state.appRoute = nil
                return .send(.handleAuthenticatedUser(user))
            
            case .loginAction(.delegate(.signUpFlowCompleted(let user))):
                state.appRoute = nil
                return .send(.handleAuthenticatedUser(user))
                
            // MARK: - profileSettingAction
            case .profileSettingAction(.delegate(.goProfileSettingView)):
                return .send(.setActiveSheet(.profileSettingView))
                            
            case .profileSettingAction(.saveProfileResponse(.success)):
                state.appRoute = nil
                return state.currentUser != nil ? .send(.fetchUserProfile(state.currentUser!.uid)) : .none
                
            // MARK: - 시트/네비게이션 Action
            case .setActiveSheet(let newSheet):
                state.appRoute = newSheet
                return .none
                
            case .dismissSheet:
                state.appRoute = nil
                return .none
                
            // MARK: - 유저 정보 확인
            case .authStatusChanged(let firebaseUser):
                return authStatusChanged(firebaseUser, state)
                
            case .handleAuthenticatedUser(let user):
                state.currentUser = user
                return .send(.fetchUserProfile(user.uid))
                            
            case .userProfileLoaded(.success(let profile)):
                return userProfileLoadedSuccess(&state, profile)
                            
            case .userProfileLoaded(.failure(let error)):
                return userProfileLoadedFailure(&state, error)

            case .navigateToProfileSetting:
                return navigateToProfileSetting(state)

            case .clearUserData:
                clearUserData(&state)
                return .none
                
            case .fetchUserProfile(let userId):
                guard state.currentUser?.uid == userId else {
                    return .none
                }
                state.isLoadingUserProfile = true
                state.userProfileError = nil
                return .run { send in
                    do {
                        let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
                        if document.exists {
                            let userProfile = try document.data(as: UserProfile.self)
                            await send(.userProfileLoaded(.success(userProfile)))
                        } else {
                            await send(.userProfileLoaded(.success(UserProfile(nickname: nil, profileImageUrl: nil, postItems: nil))))
                        }
                    } catch {
                        await send(.userProfileLoaded(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.userProfileFetch)
                
            case .onAppear:
                // 앱 시작 시 한 번만 인증 상태 리스너 등록
                guard !state.isInitialAuthCheckDone else { return .none }
                state.isInitialAuthCheckDone = true
                let handleContainer = ListenerHandleContainer()
                return .run { send in
                    await withTaskCancellationHandler {
                        let stream = AsyncStream<User?> { continuation in
                            let actualHandle = Auth.auth().addStateDidChangeListener { _, user in
                                continuation.yield(user)
                            }
                            Task { await handleContainer.setHandle(actualHandle) }
                        }
                        for await user in stream { await send(.authStatusChanged(user)) }
                    } onCancel: {
                        Task {
                            let handle = await handleContainer.getHandle()
                            if let h = handle { Auth.auth().removeStateDidChangeListener(h) }
                        }
                    }
                }
                .cancellable(id: CancelID.authStateListener)
                
            // MARK: - (_)
            case .binding(_):
                return .none

            case .dietAction(_), .analyzeAction(_), .communityAction(_), .myPageAction(_), .loginAction(_), .profileSettingAction(_):
                 return .none
            }
        }
    }
}

// MARK: - Methods
// Firebase AuthStateDidChangeListenerHandle을 안전하게 저장하고 접근하기 위한 private 액터
private actor ListenerHandleContainer {
    var handle: AuthStateDidChangeListenerHandle?

    func setHandle(_ handle: AuthStateDidChangeListenerHandle?) {
        self.handle = handle
    }

    func getHandle() -> AuthStateDidChangeListenerHandle? {
        return handle
    }
}

private func navigateToProfileSetting(_ state: AppFeature.State) -> Effect<AppFeature.Action> {
    let currentUserIsNonNil = state.currentUser != nil
    let appRouteIsNil = state.appRoute == nil
    let profileNeedsSetting = (state.userProfile == nil || state.userProfile?.isNicknameActuallySet == false)
    
    if currentUserIsNonNil && appRouteIsNil && profileNeedsSetting {
        return .send(.setActiveSheet(.profileSettingView))
    } else {
        return .none
    }
}

private func clearUserData(_ state: inout AppFeature.State) {
    state.currentUser = nil
    state.userProfile = nil
    state.isLoadingUserProfile = false
    state.userProfileError = nil
    state.appRoute = nil
}

private func userProfileLoadedFailure(_ state: inout AppFeature.State, _ error: any Error) -> Effect<AppFeature.Action> {
    state.isLoadingUserProfile = false
    state.userProfileError = "프로필 로드 실패: \(error.localizedDescription)"
    state.userProfile = nil
    return .send(.navigateToProfileSetting)
}

private func userProfileLoadedSuccess(_ state: inout AppFeature.State, _ profile: UserProfile) -> Effect<AppFeature.Action> {
    state.isLoadingUserProfile = false
    state.userProfile = profile
    return .send(.navigateToProfileSetting)
}

private func authStatusChanged(_ firebaseUser: User?, _ state: AppFeature.State) -> Effect<AppFeature.Action> {
    if let user = firebaseUser {
        if state.currentUser?.uid != user.uid {
            return .send(.handleAuthenticatedUser(user))
        } else {
            return .none
        }
    } else {
        if state.currentUser != nil {
            return .send(.clearUserData)
        }
        return .none
    }
}
