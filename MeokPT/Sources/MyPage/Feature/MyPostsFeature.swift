//
//  MyPostsFeature.swift
//  MeokPT
//
//  Created by 김동영 on 6/9/25.
//

import ComposableArchitecture
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Reducer
struct MyPostsFeature {
    
    @ObservableState
    struct State: Equatable {
        static func == (lhs: MyPostsFeature.State, rhs: MyPostsFeature.State) -> Bool {
            lhs.currentUser?.uid == rhs.currentUser?.uid &&
            lhs.postItems.count == rhs.postItems.count &&
            lhs.isLoading == rhs.isLoading
        }
        
        var currentUser: User?
        var postItems: IdentifiedArrayOf<CommunityPost> = []
        var isLoading = false
        var error: String?
        
        var filteredPosts: [CommunityPost] {
            postItems.elements
        }
        var columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case fetchCommunityPosts
        case communityPostsLoaded(Result<[CommunityPost], Error>)
    }

    
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isLoading else { return .none }
                return .send(.fetchCommunityPosts)

            case .fetchCommunityPosts:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        
                        guard let currentUser = Auth.auth().currentUser else {
                            await send(.communityPostsLoaded(.success([])))
                            return
                        }
                        
                        let querySnapshot = try await db.collection("community")
                            .whereField("userID", isEqualTo: currentUser.uid)
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
                        print("Firebase 에러: \(error.localizedDescription)")
                        await send(.communityPostsLoaded(.failure(error)))
                    }
                }
                
            case .communityPostsLoaded(.success(let posts)):
                state.isLoading = false
                state.error = nil
                // 안전하게 배열 업데이트
                state.postItems = IdentifiedArrayOf(uniqueElements: posts)
                return .none

            case .communityPostsLoaded(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                print("커뮤니티 포스트 로딩 실패: \(error)")
                return .none
                
            case .binding(_):
                return .none

            }
        }
    }
}
