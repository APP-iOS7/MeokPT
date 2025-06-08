import ComposableArchitecture
import Foundation
import _PhotosUI_SwiftUI
import FirebaseStorage
import FirebaseFirestore

@Reducer
struct CommunityEditFeature {
    @ObservableState
    struct State: Equatable {
        var communityPost: CommunityPost
        var title: String = ""
        var content: String = ""
        
        var selectedImage: UIImage?
        var selectedItem: PhotosPickerItem?
        var isUploading = false
        var uploadProgress: Double = 0.0
        var uploadedImageUrl: URL?
        var initialUploadedImageUrl: URL?

        var errorMessage: String?
        
        var selectedDiet: Diet?
        
        var postInvalid: Bool {
            title.isEmpty || content.isEmpty || selectedDiet == nil
        }
        
        var showAlert = false
        
        @Presents var mealSelectionSheet: MealSelectionFeature.State?
        
        init(communityPost: CommunityPost) {
            self.communityPost = communityPost
            self.title = communityPost.title
            self.content = communityPost.content
            self.initialUploadedImageUrl = URL(string: communityPost.photoURL)
            self.uploadedImageUrl = URL(string: communityPost.photoURL)
            self.initialUploadedImageUrl = URL(string: communityPost.photoURL)
            
            let foods = communityPost.foodList.map { communityFood in
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
            
            self.selectedDiet = Diet(
                id: UUID(),
                title: communityPost.dietName,
                isFavorite: false,
                foods: foods,
            )
        }
    }
    
    enum Action: BindableAction {
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case onAppear
        
        case mealSelectionAction(PresentationAction<MealSelectionFeature.Action>)
        case presentMealSelectionSheet
        
        case loadImageResponse(Result<UIImage, Error>)
        case initiateImageUpload
        case imageUploadCompleted(Result<URL, Error>)
        case submitButtonTapped
        case updatePost
        case updatePostResponse(Result<Void, Error>)
    }
    
    enum DelegateAction: Equatable {
        case updatePost(documentID: String, title: String, content: String, photoURL: String, diet: Diet)
        case updatePostSuccess
        case updatePostFailure(String)
    }
    
    private enum CancelID { case loadImage, imageUpload, updatePost }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.selectedItem):
                state.errorMessage = nil
                guard let pickerItem = state.selectedItem else {
                    state.selectedImage = nil
                    state.uploadedImageUrl = state.initialUploadedImageUrl
                    return .cancel(id: CancelID.loadImage)
                }
                return .run { send in
                    let result: Result<UIImage, Error> = await Result {
                        guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
                            throw NSError(domain: "ImageLoadingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                        }
                        guard let image = UIImage(data: data) else {
                            throw NSError(domain: "ImageLoadingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Conversion failed"])
                        }
                        return image
                    }
                    await send(.loadImageResponse(result))
                }
                .cancellable(id: CancelID.loadImage, cancelInFlight: true)
                
            case .onAppear:
                return .none
            case .binding(_):
                return .none
                
            case .presentMealSelectionSheet:
                state.mealSelectionSheet = MealSelectionFeature.State()
                return .none
                
            case .mealSelectionAction(.presented(.delegate(.dismissSheet))):
                state.mealSelectionSheet = nil
                return .none
                
            case .mealSelectionAction(.presented(.delegate(.selectDiet(let diet)))):
                state.mealSelectionSheet = nil
                state.selectedDiet = diet
                return .none
                
            case .mealSelectionAction(_):
                return .none
                
            case .loadImageResponse(.success(let image)):
                state.selectedImage = image
                state.errorMessage = nil
                return .send(.initiateImageUpload)
                
            case .loadImageResponse(.failure(let error)):
                state.selectedImage = nil
                state.errorMessage = error.localizedDescription
                state.uploadedImageUrl = state.initialUploadedImageUrl
                return .none
                
            case .initiateImageUpload:
                guard let imageToUpload = state.selectedImage else {
                    state.errorMessage = "업로드할 이미지가 선택되지 않았습니다."
                    return .none
                }
                state.isUploading = true
                state.uploadProgress = 0.0
                state.errorMessage = nil
                
                return .run { send in
                    let result: Result<URL, Error> = await Result {
                        guard let imageData = imageToUpload.jpegData(compressionQuality: 0.8) else {
                            throw NSError(domain: "ImageUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data conversion failed"])
                        }
                        let storageRef = Storage.storage().reference().child("community_images/\(UUID().uuidString).jpg")
                        _ = try await storageRef.putDataAsync(imageData) { progress in
                        }
                        return try await storageRef.downloadURL()
                    }
                    await send(.imageUploadCompleted(result))
                }.cancellable(id: CancelID.imageUpload, cancelInFlight: true)
                
            case .imageUploadCompleted(.success(let url)):
                state.uploadedImageUrl = url
                state.isUploading = false
                state.uploadProgress = 1.0
                return .none
                
            case .imageUploadCompleted(.failure(let error)):
                state.isUploading = false
                state.uploadedImageUrl = state.initialUploadedImageUrl
                state.selectedImage = nil
                state.selectedItem = nil
                state.errorMessage = error.localizedDescription
                return .none
                
            case .submitButtonTapped:
                guard state.selectedDiet != nil else { return .none }
                return .send(.updatePost)
                
            case .updatePost:
                guard let diet = state.selectedDiet else { return .none }
                
                let documentID = state.communityPost.documentID
                let title = state.title
                let content = state.content
                let dietTitle = diet.title
                let photoURL = state.uploadedImageUrl?.absoluteString ?? ""
                
                let foodListData = diet.foods.map { food in
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
                    let result: Result<Void, Error> = await Result {
                        let db = Firestore.firestore()
                        let documentRef = db.collection("community").document(documentID)
                        
                        let updateData: [String: Any] = [
                            "title": title,
                            "detail": content,
                            "dietName": dietTitle,
                            "photoURL": photoURL,
                            "foodList": foodListData,
                            "updatedAt": Timestamp(date: Date())
                        ]
                        
                        try await documentRef.updateData(updateData)
                    }
                    await send(.updatePostResponse(result))
                }
                .cancellable(id: CancelID.updatePost, cancelInFlight: true)
                
            case .updatePostResponse(.success):
                guard let diet = state.selectedDiet else { return .none }
                return .send(.delegate(.updatePost(
                    documentID: state.communityPost.documentID,
                    title: state.title,
                    content: state.content,
                    photoURL: state.uploadedImageUrl?.absoluteString ?? "",
                    diet: diet
                )))
                
            case .updatePostResponse(.failure(let error)):
                state.errorMessage = "게시글 수정에 실패했습니다: \(error.localizedDescription)"
                return .send(.delegate(.updatePostFailure(error.localizedDescription)))
                
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$mealSelectionSheet, action: \.mealSelectionAction) {
            MealSelectionFeature()
        }
    }
}
