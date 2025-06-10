import ComposableArchitecture
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
                    print("회원탈퇴 요청 받음")
                    return .send(.performWithdrawal)
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
            case .performWithdrawal:
                guard let currentUser = state.currentUser else {
                    print("회원탈퇴 실패: 현재 로그인된 사용자가 없습니다")
                    return .none
                }
                
                state.isLoadingUserProfile = true
                return .run { send in
                    await performCompleteWithdrawal(userId: currentUser.uid)
                }
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

private func performCompleteWithdrawal(userId: String) async {
    print("회원탈퇴 시작 - 사용자 ID: \(userId)")
    
    do {
        // 1. Storage에서 프로필 이미지 폴더 삭제
        await deleteUserProfileImages(userId: userId)
        
        // 2. Firestore에서 사용자가 작성한 커뮤니티 게시물 삭제
        await deleteUserCommunityPosts(userId: userId)
        
        // 3. Firestore에서 사용자 프로필 문서 삭제
        await deleteUserProfileDocument(userId: userId)
        
        // 4. Firebase Authentication에서 계정 삭제
        try await deleteUserAccount()
        
        print("회원탈퇴 완료")
        
    } catch {
        print("회원탈퇴 중 오류 발생: \(error.localizedDescription)")
    }
}

// MARK: - 1. Storage 프로필 이미지 삭제
private func deleteUserProfileImages(userId: String) async {
    print("1단계: Storage 프로필 이미지 폴더 삭제 시작")
    
    let storage = Storage.storage()
    let profileImagesRef = storage.reference().child("profile_images/\(userId)")
    
    do {
        // 폴더 내 모든 파일 목록 가져오기
        let listResult = try await profileImagesRef.listAll()
        
        // 각 파일 삭제
        for item in listResult.items {
            do {
                try await item.delete()
                print("삭제 완료: \(item.fullPath)")
            } catch {
                print("파일 삭제 실패: \(item.fullPath), 오류: \(error.localizedDescription)")
            }
        }
        
        print("프로필 이미지 폴더 삭제 완료")
        
    } catch {
        print("프로필 이미지 삭제 중 오류: \(error.localizedDescription)")
    }
}

// MARK: - 2. 커뮤니티 게시물 삭제
private func deleteUserCommunityPosts(userId: String) async {
    print("2단계: 커뮤니티 게시물 삭제 시작")
    
    let db = Firestore.firestore()
    
    do {
        // userId 필드로 사용자가 작성한 모든 게시물 찾기
        let querySnapshot = try await db.collection("community")
            .whereField("userID", isEqualTo: userId)
            .getDocuments()
        
        // 각 게시물 삭제
        for document in querySnapshot.documents {
            do {
                try await document.reference.delete()
                print("커뮤니티 게시물 삭제 완료: \(document.documentID)")
            } catch {
                print("커뮤니티 게시물 삭제 실패: \(document.documentID), 오류: \(error.localizedDescription)")
            }
        }
        
        print("커뮤니티 게시물 삭제 완료 - 총 \(querySnapshot.documents.count)개 삭제")
        
    } catch {
        print("커뮤니티 게시물 삭제 중 오류: \(error.localizedDescription)")
    }
}

// MARK: - 3. 사용자 프로필 문서 삭제
private func deleteUserProfileDocument(userId: String) async {
    print("3단계: 사용자 프로필 문서 삭제 시작")
    
    let db = Firestore.firestore()
    
    do {
        try await db.collection("users").document(userId).delete()
        print("사용자 프로필 문서 삭제 완료")
        
    } catch {
        print("사용자 프로필 문서 삭제 실패: \(error.localizedDescription)")
    }
}

// MARK: - 4. Firebase Authentication 계정 삭제
private func deleteUserAccount() async throws {
    print("4단계: Firebase Authentication 계정 삭제 시작")
    
    guard let user = Auth.auth().currentUser else {
        throw WithdrawalError.userNotFound
    }
    
    try await user.delete()
    print("Firebase Authentication 계정 삭제 완료")
}

// MARK: - 에러 타입 정의
enum WithdrawalError: Error, LocalizedError {
    case userNotFound
    case storageDeleteFailed
    case firestoreDeleteFailed
    case authDeleteFailed
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "로그인된 사용자를 찾을 수 없습니다"
        case .storageDeleteFailed:
            return "프로필 이미지 삭제에 실패했습니다"
        case .firestoreDeleteFailed:
            return "사용자 데이터 삭제에 실패했습니다"
        case .authDeleteFailed:
            return "계정 삭제에 실패했습니다"
        }
    }
}
