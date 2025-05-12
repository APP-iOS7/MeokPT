//
//  ProfileSettingFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/12/25.
//

import ComposableArchitecture
import _PhotosUI_SwiftUI
import SwiftUICore

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
    }
    
    private enum CancelID { case loadImage }
    
    enum ImageLoadingError: Error, Equatable {
        case noData
        case conversionFailed
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.selectedItem):
                var effects: [Effect<Action>] = [.cancel(id: CancelID.loadImage)]

                guard let pickerItem = state.selectedItem else {
                    state.selectedImage = nil
                    state.errorMessage = nil
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
                return .none
                
            case ._loadImageTaskResponse(.failure(let error)):
                state.selectedImage = nil
                if let loadingError = error as? ImageLoadingError {
                    switch loadingError {
                    case .noData:
                        state.errorMessage = "선택된 항목에서 이미지 데이터를 가져올 수 없습니다."
                    case .conversionFailed:
                        state.errorMessage = "가져온 데이터를 이미지로 변환할 수 없습니다. 다른 파일을 선택해주세요."
                    }
                } else {
                    state.errorMessage = "이미지를 로드할 수 없습니다. 다른 이미지를 선택해주세요."
                }
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}
