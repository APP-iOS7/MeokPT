import ComposableArchitecture
import Foundation
import _PhotosUI_SwiftUI
import FirebaseStorage
import FirebaseFirestore

@Reducer
struct CommunityWriteFeature {
    @ObservableState
    struct State: Equatable {
        var title: String = ""
        var content: String = ""
        
        var selectedImage: UIImage?
        var selectedItem: PhotosPickerItem?
        var isUploading = false
        var uploadProgress: Double = 0.0
        var uploadedImageUrl: URL?
        var initialUploadedImageUrl: URL?

        var errorMessage: String?

        
        @Presents var mealSelectionSheet: MealSelectionFeature.State?
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
    }
    
    enum DelegateAction: Equatable {
    }
    
    private enum CancelID { case loadImage, imageUpload }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.selectedItem):
                state.uploadedImageUrl = state.initialUploadedImageUrl
                state.errorMessage = nil
                guard let pickerItem = state.selectedItem else {
                    state.selectedImage = nil
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
            case .mealSelectionAction(_):
                return .none
            case .presentMealSelectionSheet:
                state.mealSelectionSheet = MealSelectionFeature.State()
                return .none
                
            case .loadImageResponse(.success(let image)):
                state.selectedImage = image
                state.errorMessage = nil
                return .send(.initiateImageUpload)
                
            case .loadImageResponse(.failure(let error)):
                 state.selectedImage = nil
                 state.errorMessage = error.localizedDescription
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
            }
        }
        .ifLet(\.$mealSelectionSheet, action: \.mealSelectionAction) {
            MealSelectionFeature()
        }
    }
}

