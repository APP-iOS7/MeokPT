//
//  ProfileSettingFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/12/25.
//

import ComposableArchitecture
import _PhotosUI_SwiftUI
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

@Reducer
struct ProfileSettingFeature {
    @ObservableState
    struct State {
        var selectedImage: UIImage?
        var selectedItem: PhotosPickerItem?
        var isUploading = false
        var uploadProgress: Double = 0.0
        var uploadedImageUrl: URL?
        var initialUploadedImageUrl: URL?

        var errorMessage: String?
        
        var nickName: String = ""
        var initialNickName: String = ""

        var isSavingProfile = false
        var saveProfileError: String?
        var profileSaveSuccess = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        
        case loadImageResponse(Result<UIImage, Error>)
        case initiateImageUpload
        case imageUploadProgress(Double)
        case imageUploadCompleted(Result<URL, Error>)

        case saveProfile
        case saveProfileResponse(Result<Void, Error>)
        
        case cancelButtonTapped
        case closeButtonTapped

        case onAppear
        case resetSaveStatus
    }

    enum DelegateAction: Equatable {
        case profileSettingCompleted
        case profileSettingCancelled
    }

    private enum CancelID { case loadImage, imageUpload, saveProfile }
    @Dependency(\.dismiss) var dismiss


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

            case .loadImageResponse(.success(let image)):
                state.selectedImage = image
                state.errorMessage = nil
                return .send(.initiateImageUpload)
                
            case .loadImageResponse(.failure(let error)):
                 state.selectedImage = nil
                 state.errorMessage = error.localizedDescription
                 return .none

            case .initiateImageUpload:
                guard let imageToUpload = state.selectedImage else { return .none }
                state.isUploading = true
                state.uploadProgress = 0.0
                state.errorMessage = nil
                return .run { send in
                    let result: Result<URL, Error> = await Result {
                        guard let imageData = imageToUpload.jpegData(compressionQuality: 0.8) else {
                            throw NSError(domain: "ImageUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data conversion failed"])
                        }
                        let storageRef = Storage.storage().reference().child("profile_images/\(UUID().uuidString).jpg")
                        _ = try await storageRef.putDataAsync(imageData)
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
                
            case .saveProfile:
                guard !state.nickName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    state.saveProfileError = "닉네임을 입력해주세요."
                    return .none
                }

                state.isSavingProfile = true
                state.saveProfileError = nil
                return .run { [nickName = state.nickName, imageUrl = state.uploadedImageUrl?.absoluteString, userId = Auth.auth().currentUser?.uid] send in
                    guard let uid = userId else {
                        await send(.saveProfileResponse(.failure(NSError(domain: "ProfileSaveError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))))
                        return
                    }
                    let profileData: [String: Any] = [
                        "nickname": nickName,
                        "profileImageUrl": imageUrl ?? NSNull()
                    ]
                    do {
                        try await Firestore.firestore().collection("users").document(uid).setData(profileData, merge: true)
                        await send(.saveProfileResponse(.success(())))
                        await send(.delegate(.profileSettingCompleted))
                        await self.dismiss()
                    } catch {
                        await send(.saveProfileResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.saveProfile, cancelInFlight: true)


            case .saveProfileResponse(.success):
                state.isSavingProfile = false
                state.saveProfileError = nil
                state.profileSaveSuccess = true
                state.initialNickName = state.nickName
                state.initialUploadedImageUrl = state.uploadedImageUrl
                return .none
                
            case .saveProfileResponse(.failure(let error)):
                state.isSavingProfile = false
                state.saveProfileError = error.localizedDescription
                return .none
            
            case .cancelButtonTapped:
                state.nickName = state.initialNickName
                state.uploadedImageUrl = state.initialUploadedImageUrl
                state.selectedImage = nil
                state.selectedItem = nil
                state.errorMessage = nil
                state.saveProfileError = nil
                state.isUploading = false
                state.uploadProgress = 0.0
                return .run { send in
                    await send(.delegate(.profileSettingCancelled))
                    await self.dismiss()
                }

            case .closeButtonTapped:
                return .run { send in await self.dismiss() }

            case .onAppear: return .none
            case .resetSaveStatus:
                 state.profileSaveSuccess = false
                 state.saveProfileError = nil
                 return .none
            case .delegate(_): return .none
            case .binding(_): return .none
            case .imageUploadProgress(_): return .none
            }
        }
    }
}
