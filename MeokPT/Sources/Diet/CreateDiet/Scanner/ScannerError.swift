//
//  ScannerError.swift
//  MeokPT
//
//  Created by 김동영 on 5/22/25.
//

import Foundation

enum ScannerError: Error, LocalizedError {
    case noCameraAvailable
    case inputFailed
    case metadataOutputFailed
    case noPermission(String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "사용 가능한 카메라가 없습니다."
        case .inputFailed:
            return "카메라 입력을 가져오는 데 실패했습니다."
        case .metadataOutputFailed:
            return "바코드 인식을 위한 설정을 하는 데 실패했습니다."
        case .noPermission(let message):
            return message
        case .unknownError:
            return "알 수 없는 스캐너 오류가 발생했습니다."

        }
    }
}
