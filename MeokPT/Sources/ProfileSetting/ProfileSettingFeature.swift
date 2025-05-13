//
//  ProfileSettingFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/12/25.
//

import ComposableArchitecture
import _PhotosUI_SwiftUI
import SwiftUICore
import FirebaseStorage

@Reducer
struct ProfileSettingFeature {
    
    @ObservableState
    struct State: Equatable {
        var selectedImage: UIImage?
        var selectedItem: PhotosPickerItem?
        var isUploading = false
        var uploadProgress: Double = 0.0
        var uploadedImageUrl: URL?
        var errorMessage: String?
        
        var nickName: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        
        case _loadImageTaskResponse(TaskResult<UIImage>)
        case _initiateImageUpload
        case _imageUploadProgress(Double)
        case _imageUploadCompleted(TaskResult<URL>)
    }
    
    private enum CancelID {
        case loadImage
        case imageUpload
    }
    
    enum ImageLoadingError: Error, Equatable {
        case noData
        case conversionFailed
    }
    
    enum ImageUploadError: Error, Equatable {
        case noImageSelected
        case dataConversionFailed
        case firebaseError(String)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.selectedItem):
                var effects: [Effect<Action>] = [.cancel(id: CancelID.loadImage), .cancel(id: CancelID.imageUpload)]
                state.uploadedImageUrl = nil

                guard let pickerItem = state.selectedItem else {
                    state.selectedImage = nil
                    state.errorMessage = nil
                    state.isUploading = false
                    state.uploadProgress = 0.0
                    return .concatenate(effects)
                }

                effects.append(.run { send in
                    await send(._loadImageTaskResponse(
                        TaskResult {
                            guard let data = try await pickerItem.loadTransferable(type: Data.self) else {
                                throw ImageLoadingError.noData
                            }
                            guard let image = UIImage(data: data) else {
                                throw ImageLoadingError.conversionFailed
                            }
                            return image
                        }
                    ))
                }
                .cancellable(id: CancelID.loadImage, cancelInFlight: true))
                
                return .concatenate(effects)

            case ._loadImageTaskResponse(.success(let image)):
                state.selectedImage = image
                state.errorMessage = nil
                return .send(._initiateImageUpload)
                
            case ._loadImageTaskResponse(.failure(let error)):
                state.selectedImage = nil
                state.isUploading = false
                state.uploadProgress = 0.0
                if let loadingError = error as? ImageLoadingError {
                    switch loadingError {
                    case .noData:
                        state.errorMessage = "선택된 항목에서 이미지 데이터를 가져올 수 없습니다."
                    case .conversionFailed:
                        state.errorMessage = "가져온 데이터를 이미지로 변환할 수 없습니다. 다른 파일을 선택해주세요."
                    }
                } else {
                    state.errorMessage = "이미지를 로드할 수 없습니다: \(error.localizedDescription)"
                }
                return .none
            
            case ._initiateImageUpload:
                guard let imageToUpload = state.selectedImage else {
                    state.errorMessage = "업로드할 이미지가 선택되지 않았습니다."
                    return .none
                }
                
                state.isUploading = true
                state.uploadProgress = 0.0
                state.errorMessage = nil
                state.uploadedImageUrl = nil

                return .run { send in
                    do {
                        guard let imageData = imageToUpload.jpegData(compressionQuality: 0.8) else {
                            throw ImageUploadError.dataConversionFailed
                        }
                        
                        let storage = Storage.storage()
                        let storageRef = storage.reference()
                        let imageName = UUID().uuidString + ".jpg"
                        let imageRef = storageRef.child("profile_images/\(imageName)")
                        
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"

                        let uploadTask = imageRef.putData(imageData, metadata: metadata)

                        var progressObservation: String?
                        progressObservation = uploadTask.observe(.progress) { snapshot in
                            let percentComplete = Double(snapshot.progress!.completedUnitCount)
                                / Double(snapshot.progress!.totalUnitCount)
                            Task { await send(._imageUploadProgress(percentComplete)) }
                        }
                        
                        // 업로드 완료 대기 (성공 또는 실패)
                        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                            var successObserverHandle: String?
                            var failureObserverHandle: String?

                            let cleanupObservers = {
                                if let handle = successObserverHandle { uploadTask.removeObserver(withHandle: handle) }
                                if let handle = failureObserverHandle { uploadTask.removeObserver(withHandle: handle) }
                                successObserverHandle = nil
                                failureObserverHandle = nil
                            }

                            successObserverHandle = uploadTask.observe(.success) { _ in
                                cleanupObservers()
                                continuation.resume(returning: ())
                            }

                            failureObserverHandle = uploadTask.observe(.failure) { snapshot in
                                cleanupObservers()
                                if let error = snapshot.error {
                                    continuation.resume(throwing: error)
                                } else {
                                    let genericError = NSError(domain: StorageErrorDomain,
                                                               code: StorageErrorCode.unknown.rawValue,
                                                               userInfo: [NSLocalizedDescriptionKey: "Upload failed without a specific error."])
                                    continuation.resume(throwing: genericError)
                                }
                            }
                        }
                        // 업로드 완료 후 (성공 시) 이어서 실행됨
                        let downloadURL = try await imageRef.downloadURL()
                        
                        // 진행률 관찰 중단 (성공적으로 완료된 후)
                        if let handle = progressObservation {
                             uploadTask.removeObserver(withHandle: handle)
                        }
                        await send(._imageUploadCompleted(.success(downloadURL)))
                        
                    } catch {
                        let uploadError: ImageUploadError
                        if let nsError = error as NSError?, nsError.domain == StorageErrorDomain {
                            let storageErrorCode = StorageErrorCode(rawValue: nsError.code)
                            uploadError = .firebaseError("Storage error: \(storageErrorCode?.description ?? error.localizedDescription)")
                        } else if let knownError = error as? ImageUploadError {
                            uploadError = knownError
                        }
                        else {
                            uploadError = .firebaseError(error.localizedDescription)
                        }
                        await send(._imageUploadCompleted(.failure(uploadError)))
                    }
                }
                .cancellable(id: CancelID.imageUpload, cancelInFlight: true)

            case ._imageUploadProgress(let progress):
                state.uploadProgress = progress
                return .none
                
            case ._imageUploadCompleted(.success(let url)):
                state.uploadedImageUrl = url
                state.isUploading = false
                state.uploadProgress = 1.0
                state.errorMessage = nil
                return .none
                
            case ._imageUploadCompleted(.failure(let error)):
                state.isUploading = false
                state.uploadProgress = 0.0
                if let uploadError = error as? ImageUploadError {
                     switch uploadError {
                     case .noImageSelected:
                         state.errorMessage = "업로드할 이미지가 없습니다."
                     case .dataConversionFailed:
                         state.errorMessage = "이미지를 데이터로 변환하는데 실패했습니다."
                     case .firebaseError(let specificError):
                         state.errorMessage = "Firebase 업로드 오류: \(specificError)"
                     }
                 } else {
                     state.errorMessage = "이미지 업로드 실패: \(error.localizedDescription)"
                 }
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}

extension StorageErrorCode {
    var description: String {
        switch self {
        case .objectNotFound: return "파일을 찾을 수 없습니다."
        case .unauthorized: return "권한이 없습니다."
        case .cancelled: return "업로드가 취소되었습니다."
        case .unknown: return "알 수 없는 오류가 발생했습니다."
        default: return "오류 코드: \(self.rawValue)"
        }
    }
}
