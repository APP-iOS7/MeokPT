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
    struct State: Equatable {
        var currentUser: User?
        var userProfile: UserProfile?
        
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
        
        init(currentUser: User? = nil, userProfile: UserProfile? = nil) {
            self.currentUser = currentUser
            self.userProfile = userProfile
            self.nickName = userProfile?.nickname ?? ""
            self.initialNickName = userProfile?.nickname ?? ""
            if let profileUrlString = userProfile?.profileImageUrl, let url = URL(string: profileUrlString) {
                self.uploadedImageUrl = url
                self.initialUploadedImageUrl = url
            }
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        
        case loadImageResponse(Result<UIImage, Error>)
        case initiateImageUpload
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
                guard let imageToUpload = state.selectedImage else {
                    state.errorMessage = "업로드할 이미지가 선택되지 않았습니다."
                    return .none
                }
                state.isUploading = true
                state.uploadProgress = 0.0
                state.errorMessage = nil
                state.saveProfileError = nil // 이전 저장 에러 메시지 초기화
                
                // 사용자 UID 가져오기
                guard (state.currentUser?.uid ?? Auth.auth().currentUser?.uid) != nil else {
                    state.isUploading = false
                    state.errorMessage = "사용자 인증 정보가 없어 이미지 업로드를 시작할 수 없습니다."
                    return .none
                }
                
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
                
                if state.isUploading {
                    state.saveProfileError = "프로필 사진이 업로드 중입니다. 잠시 후 다시 시도해주세요."
                    return .none
                }
                
                state.isSavingProfile = true
                state.saveProfileError = nil
                
                guard let uid = state.currentUser?.uid ?? Auth.auth().currentUser?.uid else {
                    state.isSavingProfile = false
                    state.saveProfileError = "사용자 인증 정보가 없습니다. 다시 로그인해주세요."
                    return .none
                }

                let profileData: [String: Any] = [
                    "nickname": state.nickName,
                    "profileImageUrl": state.uploadedImageUrl?.absoluteString ?? NSNull()
                ]
                
                return .run { send in
                    do {
                        try await Firestore.firestore().collection("users").document(uid).setData(profileData, merge: true)
                        await send(.saveProfileResponse(.success(())))
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
                return .run { send in
                    await send(.delegate(.profileSettingCompleted))
                    await self.dismiss()
                }
                
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
                state.profileSaveSuccess = false
                return .run { send in
                    await send(.delegate(.profileSettingCancelled))
                    await self.dismiss()
                }

            case .closeButtonTapped:
                return .run { send in await self.dismiss() }

            case .onAppear:
                state.nickName = state.userProfile?.nickname ?? state.initialNickName
                if let urlString = state.userProfile?.profileImageUrl, let url = URL(string: urlString) {
                    state.uploadedImageUrl = url
                    state.initialUploadedImageUrl = url
                }
                state.profileSaveSuccess = false
                state.saveProfileError = nil
                state.errorMessage = nil
                return .none
                
            case .resetSaveStatus:
                state.profileSaveSuccess = false
                state.saveProfileError = nil
                return .none
                
            case .delegate: return .none
            case .binding: return .none
            }
        }
    }
}
