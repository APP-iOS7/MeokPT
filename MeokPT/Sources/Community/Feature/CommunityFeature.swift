import ComposableArchitecture
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Reducer
struct CommunityFeature {
    
    @Reducer
    enum Path {
        case addPost(CommunityWriteFeature)
        case detailPost(CommunityDetailFeature)
    }
    
    @ObservableState
    struct State: Equatable{
        static func == (lhs: CommunityFeature.State, rhs: CommunityFeature.State) -> Bool {
            lhs.searchText == rhs.searchText
        }
        var columns = [
            GridItem(.flexible()),
            GridItem(.flexible())

        ]
        var currentUser: User?
        var userProfile: UserProfile?
        
        var postItems: IdentifiedArrayOf<CommunityPost> = []
        var searchText: String = ""

        var filteredPosts: [CommunityPost] {
            searchText.isEmpty ? postItems.elements : postItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.dietName.localizedCaseInsensitiveContains(searchText) }
        }
        
        var showAlert = false
        var showAlertToast = false
        var toastMessage = ""
        var isSuccess = false
        
        var path = StackState<Path.State>()
    }
    
    enum Action: BindableAction{
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
       
        case onAppear
        case fetchCommunityPosts
        case communityPostsLoaded(Result<[CommunityPost], Error>)
        
        case path(StackActionOf<Path>)
        case navigateToAddButtonTapped
        case navigateToPostItemTapped(id: UUID)
        case presentLogin
        
        case postSavedSuccessfully
        case postSaveError(Error)
        
        case hideToast
        
        case postDeletedSuccessfully
        case postDeleteError(Error)
    }
    
    enum DelegateAction: Equatable {
        case presentLogin
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchCommunityPosts)

            case .fetchCommunityPosts:
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        
                        // createdAt 기준으로 내림차순 정렬하여 최신 글부터 가져오기
                        let querySnapshot = try await db.collection("community")
                            .order(by: "createdAt", descending: true)
                            .getDocuments()
                        
                        let posts: [CommunityPost] = querySnapshot.documents.compactMap { document in
                            let data = document.data()
                            
                            // 필수 필드들 확인
                            guard let title = data["title"] as? String,
                                  let detail = data["detail"] as? String,
                                  let dietName = data["dietName"] as? String,
                                  let photoURL = data["photoURL"] as? String,
                                  let userID = data["userID"] as? String,
                                  let userNickname = data["userNickname"] as? String,
                                  let userProfileImageURL = data["userProfileImageURL"] as? String,
                                  let sharedCount = data["sharedCount"] as? Int,
                                  let createdAtTimestamp = data["createdAt"] as? Timestamp,
                                  let foodListData = data["foodList"] as? [[String: Any]],
                                  let documentID = data["documentID"] as? String
                            else {
                                print("필수 필드가 누락된 문서: \(document.documentID)")
                                return nil
                            }
                            
                            // updatedAt은 옵셔널로 처리
                            let updatedAt: Date? = (data["updatedAt"] as? Timestamp)?.dateValue()
                            
                            // foodList 변환
                            let foodList: [CommunityFoodList] = foodListData.compactMap { foodData in
                                guard let foodName = foodData["foodName"] as? String,
                                      let amount = foodData["amount"] as? Double,
                                      let kcal = foodData["kcal"] as? Double
                                else {
                                    return nil
                                }
                                
                                return CommunityFoodList(
                                    foodName: foodName,
                                    amount: amount,
                                    kcal: kcal,
                                    carbohydrate: foodData["carbohydrate"] as? Double,
                                    protein: foodData["protein"] as? Double,
                                    fat: foodData["fat"] as? Double,
                                    dietaryFiber: foodData["dietaryFiber"] as? Double,
                                    sodium: foodData["sodium"] as? Double,
                                    sugar: foodData["sugar"] as? Double
                                )
                            }
                            
                            return CommunityPost(
                                sharedCount: sharedCount,
                                documentID: documentID,
                                createdAt: createdAtTimestamp.dateValue(),
                                updatedAt: updatedAt,
                                title: title,
                                content: detail,
                                dietName: dietName,
                                photoURL: photoURL,
                                userID: userID,
                                userNickname: userNickname,
                                userProfileImageURL: userProfileImageURL,
                                foodList: foodList
                            )
                        }
                        
                        await send(.communityPostsLoaded(.success(posts)))
                        
                    } catch {
                        await send(.communityPostsLoaded(.failure(error)))
                    }
                }
                
            case .communityPostsLoaded(.success(let posts)):
                state.postItems = IdentifiedArrayOf(uniqueElements: posts)
                return .none

            case .communityPostsLoaded(.failure(let error)):
                print("커뮤니티 포스트 로딩 실패: \(error)")
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
                
            case .navigateToPostItemTapped(let id):
                if let post = state.postItems[id: id] {
                    let detailState = CommunityDetailFeature.State(
                        communityPost: post
                    )
                    state.path.append(.detailPost(detailState))
                }
                return .none
                
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
                        
                        let documentRef = db.collection("community").document()
                        let documentID = documentRef.documentID
                        
                        // Firestore에 저장할 데이터 구성
                        let postData: [String: Any] = [
                            "documentID": documentID,
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
                        try await documentRef.setData(postData)
                        
                        // users 컬렉션의 postItems 업데이트
                        let userRef = db.collection("users").document(userID)
                        try await userRef.updateData([
                            "postItems": FieldValue.arrayUnion([documentID])
                        ])
                        
                        await send(.postSavedSuccessfully)
                        
                    } catch {
                        await send(.postSaveError(error))
                    }
                }
                
            case .path(.element(id: _, action: .detailPost(.delegate(.deletePost(let docID))))):
                state.path.removeAll()
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        guard let currentUser = Auth.auth().currentUser else {
                            await send(.postDeleteError(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어 있지 않습니다."])))
                            return
                        }
                        
                        let userID = currentUser.uid
                        
                        // 1. community 컬렉션에서 게시글 삭제
                        try await db.collection("community").document(docID).delete()
                        
                        // 2. users 컬렉션의 postItems 배열에서 해당 documentID 제거
                        let userRef = db.collection("users").document(userID)
                        try await userRef.updateData([
                            "postItems": FieldValue.arrayRemove([docID])
                        ])
                        
                        await send(.postDeletedSuccessfully)
                        
                    } catch {
                        await send(.postDeleteError(error))
                    }
                }

            case .postDeletedSuccessfully:
                state.isSuccess = true
                state.toastMessage = "게시글이 삭제되었습니다."
                state.showAlertToast = true
                return .merge(
                    .run { send in
                        try await Task.sleep(for: .seconds(3))
                        await send(.hideToast)
                    },
                    .send(.fetchCommunityPosts) // 삭제 후 게시글 목록 새로고침
                )

            case .postDeleteError(let error):
                print("게시글 삭제 실패: \(error.localizedDescription)")
                state.toastMessage = "게시글 삭제에 실패했습니다."
                state.showAlertToast = true
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
            case .postSavedSuccessfully:
                state.path.removeAll()
                state.isSuccess = true
                state.toastMessage = "작성 글을 게시하였습니다."
                state.showAlertToast = true
                return .merge(
                    .run { send in
                        try await Task.sleep(for: .seconds(3))
                        await send(.hideToast)
                    },
                    .send(.fetchCommunityPosts)
                )
                
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
        .forEach(\.path, action: \.path)
    }
}

