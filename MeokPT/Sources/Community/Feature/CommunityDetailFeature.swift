import ComposableArchitecture
import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseAuth

@Reducer
struct CommunityDetailFeature {
    @ObservableState
    struct State: Equatable{
        @Presents var editPostFullScreenCover: CommunityEditFeature.State?
        
        var communityPost: CommunityPost
        var hasSharedBefore: Bool = false
        var showAlert: Bool = false
        var showAlertToast: Bool = false
        var toastMessage: String = ""
        
        var isMyPost: Bool {
            if let currentUser = Auth.auth().currentUser {
                return currentUser.uid == communityPost.userID
            } else {
                return false
            }
        }
        
        var formattedDate: String {
            let now = Date()
            let targetDate = communityPost.updatedAt ?? communityPost.createdAt
            let timeInterval = now.timeIntervalSince(targetDate)
            
            let minutes = Int(timeInterval / 60)
            let hours = Int(timeInterval / 3600)
            let days = Int(timeInterval / 86400)
            
            var dateString: String
            
            if minutes < 1 {
                dateString = "방금 전"
            } else if minutes < 60 {
                dateString = "\(minutes)분 전"
            } else if hours < 24 {
                dateString = "\(hours)시간 전"
            } else if days <= 3 {
                dateString = "\(days)일 전"
            } else {
                let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M월 d일"
                    return formatter
                }()
                dateString = dateFormatter.string(from: targetDate)
            }
            
            // updatedAt 이 존재하면 수정 표시 추가
            if communityPost.updatedAt != nil {
                dateString += " (수정)"
            }
            
            return dateString
        }
        
        var kcal: Double {
            communityPost.foodList.compactMap { $0.kcal }.reduce(0.0, +)
        }
        var carbohydrate: Double {
            communityPost.foodList.compactMap { $0.carbohydrate }.reduce(0.0, +)
        }
        var protein: Double {
            communityPost.foodList.compactMap { $0.protein }.reduce(0.0, +)
        }
        var fat: Double {
            communityPost.foodList.compactMap { $0.fat }.reduce(0.0, +)
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case checkIfSharedBefore
        case getShareButtonTapped
        case dietCreated(CommunityPost)
        case incrementShareCount(String)
        case recordSharedPost(String)
        case hideToast
        case updateButtonTapped
        case deleteButtonTapped
        case deletePost
        
        case editPostFullScreenCover(PresentationAction<CommunityEditFeature.Action>)
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case updatePost(String)
        case deletePost(String)
    }
    
    @Dependency(\.modelContainer) var modelContainer

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.checkIfSharedBefore)
                
            case .checkIfSharedBefore:
                return .run { [communityPost = state.communityPost] send in
                    let hasShared = await checkIfPostSharedBefore(documentID: communityPost.documentID)
                        await send(.binding(.set(\.hasSharedBefore, hasShared)))
                }

            case .getShareButtonTapped:
                if state.hasSharedBefore {
                    // 이미 공유했으면 카운트 증가 없이 식단 저장
                    state.toastMessage = "내 식단 리스트에 다시 추가하였습니다."
                    state.showAlertToast = true
                    return .merge(
                        .send(.dietCreated(state.communityPost)),
                        .run { send in
                            try await Task.sleep(for: .seconds(3))
                            await send(.hideToast)
                        }
                    )
                } else {
                    // 처음 공유하면 카운트 증가, 식단 저장, 카운트 증가
                    state.toastMessage = "내 식단 리스트에 추가하였습니다."
                    state.showAlertToast = true
                    state.hasSharedBefore = true
                    state.communityPost.sharedCount += 1    // UI 업데이트
                    return .merge(
                        .send(.dietCreated(state.communityPost)),
                        .send(.incrementShareCount(state.communityPost.documentID)),
                        .send(.recordSharedPost(state.communityPost.documentID)),
                        .run { send in
                            try await Task.sleep(for: .seconds(3))
                            await send(.hideToast)
                        }
                    )
                }
                
            case .dietCreated(let communityPost):
                return .run { send in
                    await MainActor.run {
                        let foods: [Food] = communityPost.foodList.map { communityFood in
                            Food(
                                name: communityFood.foodName,
                                amount: communityFood.amount,
                                kcal: communityFood.kcal,
                                carbohydrate: communityFood.carbohydrate,
                                protein: communityFood.protein,
                                fat: communityFood.fat,
                                dietaryFiber: communityFood.dietaryFiber,
                                sodium: communityFood.sodium,
                                sugar: communityFood.sugar
                            )
                        }
                        let context = modelContainer.mainContext
                        let newDiet = Diet(title: communityPost.dietName, isFavorite: false, foods: foods)
                        context.insert(newDiet)
                        
                        do {
                            try context.save()
                        } catch {
                            print("SwiftData 저장 실패: \(error)")
                        }
                    }
                }
                
            case .incrementShareCount(let id):
                return .run { send in
                    do {
                        let db = Firestore.firestore()
                        let userRef = db.collection("community").document(id)
                        try await userRef.updateData([
                            "sharedCount": FieldValue.increment(Int64(1))
                        ])
                    } catch {
                        print("Firestore 업데이트 실패: \(error)")
                    }
                }
                
            // 이 식단을 저장한 기록을 SwiftData에 저장
            case .recordSharedPost(let documentID):
                return .run { send in
                    await MainActor.run {
                        let context = modelContainer.mainContext
                        let sharedRecord = SharedPostRecord(communityPostID: documentID, sharedAt: Date())
                        context.insert(sharedRecord)
                        
                        do {
                            try context.save()
                        } catch {
                            print("공유 기록 저장 실패: \(error)")
                        }
                    }
                }
                
            case .hideToast:
                state.showAlertToast = false
                return .none
                
            case .updateButtonTapped:
                state.editPostFullScreenCover = CommunityEditFeature.State(communityPost: state.communityPost)
                return .none
                
            case .editPostFullScreenCover(.presented(.delegate(.updatePost(let documentID, let title, let content, let photoURL, let diet)))):
                let updatedFoodList = diet.foods.map { food in
                    CommunityFoodList(
                        foodName: food.name,
                        amount: food.amount,
                        kcal: food.kcal,
                        carbohydrate: food.carbohydrate,
                        protein: food.protein,
                        fat: food.fat,
                        dietaryFiber: food.dietaryFiber,
                        sodium: food.sodium,
                        sugar: food.sugar
                    )
                }
                
                let updatedPost = CommunityPost(
                    sharedCount: state.communityPost.sharedCount,
                    documentID: documentID,
                    createdAt: state.communityPost.createdAt,
                    updatedAt: Date(),
                    title: title,
                    content: content,
                    dietName: diet.title,
                    photoURL: photoURL,
                    userID: state.communityPost.userID,
                    userNickname: state.communityPost.userNickname,
                    userProfileImageURL: state.communityPost.userProfileImageURL,
                    foodList: updatedFoodList

                )
                state.communityPost = updatedPost // UI 업데이트
                state.editPostFullScreenCover = nil
                return .none
                                
            case .editPostFullScreenCover(.presented(.delegate(.updatePostFailure(let errorMessage)))):
                state.toastMessage = errorMessage
                state.showAlertToast = true
                state.editPostFullScreenCover = nil
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
            case .editPostFullScreenCover(.dismiss):
                state.editPostFullScreenCover = nil
                return .none

            case .deleteButtonTapped:
                state.showAlert = true
                return .none
                
            case .deletePost:
                return .send(.delegate(.deletePost(state.communityPost.documentID)))
                
            case .binding(_):
                return .none
            case .delegate(_):
                return .none

            case .editPostFullScreenCover(_):
                return .none
            }
        }
        .ifLet(\.$editPostFullScreenCover, action: \.editPostFullScreenCover) { CommunityEditFeature() }
    }
    
    // 이전에 공유했는지 확인하는 함수
    private func checkIfPostSharedBefore(documentID: String) async -> Bool {
        return await MainActor.run {
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<SharedPostRecord>(
                predicate: #Predicate { $0.communityPostID == documentID }
            )
            
            do {
                let results = try context.fetch(descriptor)
                return !results.isEmpty
            } catch {
                print("공유 기록 조회 실패: \(error)")
                return false
            }
        }
    }
}

