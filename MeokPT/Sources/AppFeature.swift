import ComposableArchitecture
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State {
        var dietState = DietFeature.State()
        var analyzeState = DailyNutritionDietInfoFeature.State()
        var communityState = CommunityFeature.State()
        var myPageState = MyPageFeature.State()
        
        @Presents var loginModal: LoginFeature.State?
        @Presents var profileSettingModal: ProfileSettingFeature.State?
        @Presents var dietSelectionModal: DietSelectionModalFeature.State?
        @Presents var aiModal: AIModalFeature.State?
        
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
        
        case loginModalAction(PresentationAction<LoginFeature.Action>)
        case profileSettingModalAction(PresentationAction<ProfileSettingFeature.Action>)
        case dietSelectionModalAction(PresentationAction<DietSelectionModalFeature.Action>)
        case aiModalAction(PresentationAction<AIModalFeature.Action>)
        
        case presentLoginModal
        case presentProfileSettingModal
        case presentDietSelectionModal
        case presentAIModal
        
        case authStatusChanged(User?)
        case handleAuthenticatedUser(User)
        case userProfileLoaded(Result<UserProfile, Error>)
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
        
        Scope(state: \.dietState, action: \.dietAction) { DietFeature() }
        Scope(state: \.analyzeState, action: \.analyzeAction) { DailyNutritionDietInfoFeature() }
        Scope(state: \.communityState, action: \.communityAction) { CommunityFeature() }
        Scope(state: \.myPageState, action: \.myPageAction) { MyPageFeature() }
        
        Reduce { state, action in
            switch action {
            // MARK: - TabView 에 포함된 뷰의 Action
            case .dietAction(_):
                return .none
                
            case .analyzeAction(.dietSelectionDelegate(.toDietSelectionModalView)):
                return .send(.presentDietSelectionModal)
                
            case .analyzeAction(.AIModalDelegate(.toAIModalView)):
                return .send(.presentAIModal)
                
            case .communityAction(_):
                return .none
                
            case .myPageAction(.delegate(.loginSignUpButtonTapped)):
                return .send(.presentLoginModal)
                
            // MARK: - 모달에 표시되는 뷰의 Action
            case .loginModalAction(.presented(.delegate(.dismissLoginSheet))):
                state.loginModal = nil
                return .none
                
            case .loginModalAction(.presented(.delegate(.loginSuccessfully(let user)))):
                state.loginModal = nil
                return .send(.handleAuthenticatedUser(user))
                
            case .loginModalAction(.presented(.delegate(.signUpFlowCompleted(let user)))):
                state.loginModal = nil
                return .send(.handleAuthenticatedUser(user))
                
            case .profileSettingModalAction(.presented(.delegate(.profileSettingCompleted))):
                state.profileSettingModal = nil
                return state.currentUser != nil ? .send(.fetchUserProfile(state.currentUser!.uid)) : .none
                
            case .profileSettingModalAction(.presented(.saveProfileResponse(.success))):
                state.profileSettingModal = nil
                return state.currentUser != nil ? .send(.fetchUserProfile(state.currentUser!.uid)) : .none
                
            // MARK: - @Presents 사용으로 필수로 작성해야 하는 present Action
            case .presentLoginModal:
                state.loginModal = LoginFeature.State()
                return .none
                
            case .presentProfileSettingModal:
                state.profileSettingModal = ProfileSettingFeature.State()
                return .none
                
            case .presentDietSelectionModal:
                state.dietSelectionModal = DietSelectionModalFeature.State()
                return .none
                
            case .presentAIModal:
                state.aiModal = AIModalFeature.State()
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
                
            case .clearUserData:
                return clearUserData(&state)
                
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
                
            case .analyzeAction, .myPageAction, .loginModalAction, .profileSettingModalAction, .dietSelectionModalAction, .aiModalAction:
                return .none
            }
        }
        .ifLet(\.$loginModal, action: \.loginModalAction) {
            LoginFeature()
        }
        .ifLet(\.$profileSettingModal, action: \.profileSettingModalAction) {
            ProfileSettingFeature()
        }
        .ifLet(\.$dietSelectionModal, action: \.dietSelectionModalAction) {
            DietSelectionModalFeature()
        }
        .ifLet(\.$aiModal, action: \.aiModalAction) {
            AIModalFeature()
        }
    }
}

// MARK: - Methods
// Firebase AuthStateDidChangeListenerHandle을 안전하게 저장하고 접근하기 위한 private 액터
private actor ListenerHandleContainer {
    var handle: AuthStateDidChangeListenerHandle?
    func setHandle(_ handle: AuthStateDidChangeListenerHandle?) { self.handle = handle }
    func getHandle() -> AuthStateDidChangeListenerHandle? { return handle }
}

private func authStatusChanged(_ firebaseUser: User?, _ state: AppFeature.State) -> Effect<AppFeature.Action> {
    if let user = firebaseUser {
        if state.currentUser?.uid != user.uid {
            return .send(.handleAuthenticatedUser(user))
        }
        return .none
    } else {
        if state.currentUser != nil {
            return .send(.clearUserData)
        }
        return .none
    }
}

private func userProfileLoadedSuccess(_ state: inout AppFeature.State, _ profile: UserProfile) -> Effect<AppFeature.Action> {
    state.isLoadingUserProfile = false
    state.userProfile = profile
    if profile.nickname == nil || profile.nickname?.isEmpty == true {
        return .send(.presentProfileSettingModal)
    }
    return .none
}

private func userProfileLoadedFailure(_ state: inout AppFeature.State, _ error: any Error) -> Effect<AppFeature.Action> {
    state.isLoadingUserProfile = false
    state.userProfileError = "프로필 로드 실패: \(error.localizedDescription)"
    state.userProfile = nil
    return .send(.presentProfileSettingModal)
}

private func clearUserData(_ state: inout AppFeature.State) -> Effect<AppFeature.Action> {
    state.currentUser = nil
    state.userProfile = nil
    state.isLoadingUserProfile = false
    state.userProfileError = nil
    state.loginModal = nil
    state.profileSettingModal = nil
    state.dietSelectionModal = nil
    state.aiModal = nil
    return .none
}
