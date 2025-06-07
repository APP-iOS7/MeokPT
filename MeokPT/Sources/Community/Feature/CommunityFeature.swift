import ComposableArchitecture
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Reducer
struct CommunityPath {
    @ObservableState
    enum State: Equatable {
        case addPost(CommunityWriteFeature.State)
    }

    enum Action {
        case addPost(CommunityWriteFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.addPost, action: \.addPost) {
            CommunityWriteFeature()
        }
    }
}

@Reducer
struct CommunityFeature {
    @ObservableState
    struct State: Equatable{
        static func == (lhs: CommunityFeature.State, rhs: CommunityFeature.State) -> Bool {
            lhs.searchText == rhs.searchText &&
            lhs.path == rhs.path
        }
        
        var currentUser: User?
        var userProfile: UserProfile?
        
        var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)
        var searchText: String = ""
        
        var showAlert = false
        var showAlertToast = false
        var toastMessage = ""
        var isSuccess = false
        
        var path = StackState<CommunityPath.State>()
    }
    
    enum Action: BindableAction{
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case onAppear
        
        case path(StackAction<CommunityPath.State, CommunityPath.Action>) // 스택 변경 및 요소 액션 처리
        case navigateToAddButtonTapped
        case presentLogin
        
        case postSavedSuccessfully
        case postSaveError(Error)
        
        case hideToast
    }
    
    enum DelegateAction: Equatable {
        case presentLogin
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .navigateToAddButtonTapped:
                if state.currentUser == nil {
                    state.showAlert = true
                } else {
                    state.path.append(.addPost(CommunityWriteFeature.State()))
                }
                return .none
                
            case .presentLogin:
                return .send(.delegate(.presentLogin))
                
            case .path(.element(id: _, action: .addPost(.delegate(.createPost(let title, let content, let photoURL, let diet))))):
                guard let currentUser = Auth.auth().currentUser else {
                    return .send(.postSaveError(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."])))
                }
                
                let userNickname = state.userProfile?.nickname ?? ""
                let userProfileImageURL = state.userProfile?.profileImageUrl ?? ""
                let userID = currentUser.uid
                let dietTitle = diet.title
                let foodList = diet.foods.map { food in
                    return [
                        "foodName": food.name,
                        "amount": food.amount,
                        "kcal": food.kcal,
                        "carbohydrate": food.carbohydrate ?? 0.0,
                        "protein": food.protein ?? 0.0,
                        "fat": food.fat ?? 0.0,
                        "dietaryFiber": food.dietaryFiber ?? 0.0,
                        "sugar": food.sugar ?? 0.0,
                        "sodium": food.sodium ?? 0.0
                    ] as [String: Any]
                }
                
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        
                        // Firestore에 저장할 데이터 구성
                        let postData: [String: Any] = [
                            "userNickname": userNickname,
                            "userProfileImageURL": userProfileImageURL,
                            "sharedCount": 0,
                            "createdAt": Timestamp(date: Date()),
                            "userID": userID,
                            "title": title,
                            "detail": content,
                            "dietName": dietTitle,
                            "photoURL": photoURL,
                            "foodList": foodList
                        ]
                        
                        // 커뮤니티 포스트 저장
                        let documentRef = try await db.collection("community").addDocument(data: postData)
                        
                        // users 컬렉션의 postItems 업데이트
                        let userRef = db.collection("users").document(userID)
                        try await userRef.updateData([
                            "postItems": FieldValue.arrayUnion([documentRef.documentID])
                        ])
                        
                        await send(.postSavedSuccessfully)
                        
                    } catch {
                        await send(.postSaveError(error))
                    }
                }
                
            case .postSavedSuccessfully:
                state.path.removeAll()
                state.isSuccess = true
                state.toastMessage = "작성 글을 게시하였습니다."
                state.showAlertToast = true
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
            case .postSaveError(let error):
                state.path.removeAll()
                print("포스트 저장 실패: \(error.localizedDescription)")
                state.toastMessage = "글 게시에 실패했습니다."
                state.showAlertToast = true
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
            case .hideToast:
                state.showAlertToast = false
                return .none
                
            case .binding(_):
                return .none
            case .path(_):
                return .none
            case .delegate(_):
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            CommunityPath()
        }
    }
}

