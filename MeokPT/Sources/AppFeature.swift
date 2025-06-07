import ComposableArchitecture
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State {
        var selectedTab: Tab = .diet
        var dietState = DietFeature.State()
        var analyzeState = DailyNutritionDietInfoFeature.State()
        var communityState = CommunityFeature.State()
        var myPageState = MyPageFeature.State()
        
        @Presents var loginFullScreenCover: LoginFeature.State?
        @Presents var profileSettingFullScreenCover: ProfileSettingFeature.State?
        
        var currentUser: User?
        var userProfile: UserProfile?
        var isLoadingUserProfile: Bool = false
        var userProfileError: String?
        var isInitialAuthCheckDone: Bool = false
        
        enum Tab: Hashable {
            case diet, analyze, community, myPage
        }
    }
    
    enum Action: BindableAction {
        case setSelectedTab(State.Tab)
        
        case binding(BindingAction<State>)
        case dietAction(DietFeature.Action)
        case analyzeAction(DailyNutritionDietInfoFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
        
        case loginAction(PresentationAction<LoginFeature.Action>)
        case profileSettingAction(PresentationAction<ProfileSettingFeature.Action>)
        
        case presentLoginFullScreenCover
        case presentprofileSettingFullScreenCover
        
        case authStatusChanged(User?)
        case handleAuthenticatedUser(User)
        case userProfileLoaded(Result<UserProfile, Error>)
        case clearUserData
        case fetchUserProfile(String)
        case performLogout
        case performWithdrawal
        
        case onAppear
    }

    enum CancelID {
        case userProfileFetch
        case authStateListener
        case logoutRequest
        case withdrawalRequest
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Scope(state: \.dietState, action: \.dietAction) { DietFeature() }
        Scope(state: \.analyzeState, action: \.analyzeAction) { DailyNutritionDietInfoFeature() }
        Scope(state: \.communityState, action: \.communityAction) { CommunityFeature() }
        Scope(state: \.myPageState, action: \.myPageAction) { MyPageFeature() }
        
        Reduce { state, action in
            switch action {
            case .communityAction(.delegate(.presentLogin)):
                return .send(.presentLoginFullScreenCover)

            case .myPageAction(.delegate(let myPageDelegateAction)):
                switch myPageDelegateAction {
                case .loginSignUpButtonTapped:
                    return .send(.presentLoginFullScreenCover)
                case .profileSettingButtonTapped:
                    return .send(.presentprofileSettingFullScreenCover)
                case .requestLogout:
                    return .send(.performLogout)
                case .requestWithdrawal:
                    print("회원탈퇴 요청 받음 - 확인 절차 및 실제 탈퇴 로직 구현 필요")
                    return .none
                }
                
            // MARK: - 모달에 표시되는 뷰의 Action
            case .loginAction(.presented(.delegate(.dismissLoginSheet))):
                state.loginFullScreenCover = nil
                return .none
                
            case .loginAction(.presented(.delegate(.loginSuccessfully(let user)))):
                state.loginFullScreenCover = nil
                return .send(.handleAuthenticatedUser(user))
                
            case .loginAction(.presented(.delegate(.signUpFlowCompleted(let user)))):
                state.loginFullScreenCover = nil
                return .send(.handleAuthenticatedUser(user))
                
            case .profileSettingAction(.presented(.delegate(.profileSettingCancelled))):
                state.profileSettingFullScreenCover = nil
                return .none
                
            case .profileSettingAction(.presented(.delegate(.profileSettingCompleted))):
                state.profileSettingFullScreenCover = nil
                return state.currentUser != nil ? .send(.fetchUserProfile(state.currentUser!.uid)) : .none
                
            case .profileSettingAction(.presented(.saveProfileResponse(.success))):
                return .none
                
            // MARK: - @Presents 사용으로 필수로 작성해야 하는 present Action
            case .presentLoginFullScreenCover:
                if state.profileSettingFullScreenCover != nil {
                    return .none
                }
                state.loginFullScreenCover = LoginFeature.State()
                return .none
                
            case .presentprofileSettingFullScreenCover:
                if state.loginFullScreenCover != nil {
                    return .none
                }
                state.profileSettingFullScreenCover = ProfileSettingFeature.State(
                     currentUser: state.currentUser,
                     userProfile: state.userProfile
                )
                return .none
                
            // MARK: - 유저 정보 확인 및 관리
            case .authStatusChanged(let firebaseUser):
                var effects: [Effect<Action>] = []

                if let user = firebaseUser {
                    if state.currentUser == nil || state.currentUser?.uid != user.uid {
                        effects.append(.send(.handleAuthenticatedUser(user)))
                    }
                    state.myPageState.currentUser = user
                    state.myPageState.userProfile = state.userProfile
                    state.communityState.currentUser = user
                    state.communityState.userProfile = state.userProfile
                } else {
                    if state.currentUser != nil {
                        clearUserData(&state)
                        
                        effects.append(.cancel(id: CancelID.userProfileFetch))
                    } else {
                        state.myPageState.currentUser = nil
                        state.myPageState.userProfile = nil
                        state.communityState.currentUser = nil
                        state.communityState.userProfile = nil
                    }
                }
                return .merge(effects)
                
            case .handleAuthenticatedUser(let user):
                state.currentUser = user
                state.userProfile = nil
                state.isLoadingUserProfile = false
                state.userProfileError = nil
                
                // MyPageFeature 상태 업데이트
                state.myPageState.currentUser = user
                state.myPageState.userProfile = nil
                state.communityState.currentUser = user
                state.communityState.userProfile = nil
                
                return .send(.fetchUserProfile(user.uid))
                            
            case .userProfileLoaded(.success(let profile)):
                state.isLoadingUserProfile = false
                state.userProfile = profile
                // MyPageFeature 상태 업데이트
                state.myPageState.userProfile = profile
                state.communityState.userProfile = profile
                
                if state.currentUser != nil && (profile.nickname == nil || profile.nickname?.isEmpty == true) {
                    return .run { send in
                        await Task.yield()
                        await send(.presentprofileSettingFullScreenCover)
                    }
                }
                return .none
                                
            case .userProfileLoaded(.failure(let error)):
                state.isLoadingUserProfile = false
                state.userProfileError = "프로필 로드 실패: \(error.localizedDescription)"
                state.userProfile = nil
                // MyPageFeature 상태 업데이트
                state.myPageState.userProfile = nil
                state.communityState.userProfile = nil
                
                if state.currentUser != nil {
                     return .run { send in
                        await Task.yield()
                        await send(.presentprofileSettingFullScreenCover)
                    }
                }
                return .none
                
            case .clearUserData:
                clearUserData(&state)
                return .cancel(id: CancelID.userProfileFetch)
                
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

            case .performLogout:
                state.isLoadingUserProfile = true
                return .run { send in
                    do {
                        try Auth.auth().signOut()
                        print("로그아웃 성공 (Firebase)")
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }
                .cancellable(id: CancelID.logoutRequest)

            case .performWithdrawal:
                print("회원탈퇴 로직 수행 - 구현 필요")
                return .none
                .cancellable(id: CancelID.withdrawalRequest)
                
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
                
            case .setSelectedTab(let tab):
                state.selectedTab = tab
                return .none
            case .analyzeAction(.delegate(let analyzeDelegateAction)):
                switch analyzeDelegateAction {
                case .navigateToMyPage:
                    state.selectedTab = .myPage 
                    return .none
            }
            case .binding, .dietAction, .analyzeAction, .communityAction, .myPageAction, .loginAction, .profileSettingAction:
                return .none
            }
        }
        .ifLet(\.$loginFullScreenCover, action: \.loginAction) {
            LoginFeature()
        }
        .ifLet(\.$profileSettingFullScreenCover, action: \.profileSettingAction) {
            ProfileSettingFeature()
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

private func clearUserData(_ state: inout AppFeature.State) {
    state.currentUser = nil
    state.userProfile = nil
    state.isLoadingUserProfile = false
    state.userProfileError = nil
    state.loginFullScreenCover = nil
    state.profileSettingFullScreenCover = nil
    
    state.myPageState.currentUser = nil
    state.myPageState.userProfile = nil
    state.communityState.currentUser = nil
    state.communityState.userProfile = nil
}
