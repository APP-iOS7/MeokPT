//
//  APIClient.swift
//  MeokPT
//
//  Created by 김동영 on 5/20/25.
//

import Alamofire
import Foundation
import ComposableArchitecture

enum APIConstants {
    static let serviceKey = "rG1rILvTxLQzzMdurCFALWpyOWZc6UKwB/e0ieF0erC7T3LUHQeXwowB4bvfoVBeEQrloeOmi4GMJBb8CLgw1w=="
    static let baseURL = "https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02"
}

struct FoodNutritionClient {
    var fetch: (_ foodName: String, _ pageNo: Int, _ numOfRows: Int, _ serviceKey: String) async throws -> FoodNutritionAPIResponse
}

struct FoodNutritionAPIResponse: Decodable, Equatable {
    let header: Header
    let body: Body?
    
    struct Header: Decodable, Equatable {
        let resultCode: String
        let resultMsg: String
    }
    
    struct Body: Decodable, Equatable {
        let pageNo: Int?
        let totalCount: Int?
        let numOfRows: Int?
        let items: [FoodNutritionItem]?
    }
}

extension FoodNutritionClient: DependencyKey {
    static let liveValue = Self(
        fetch: { foodName, pageNo, numOfRows, serviceKey in
            var components = URLComponents(string: APIConstants.baseURL)
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "serviceKey", value: serviceKey),
                URLQueryItem(name: "pageNo", value: String(pageNo)),
                URLQueryItem(name: "numOfRows", value: String(numOfRows)),
                URLQueryItem(name: "type", value: "json"),
                URLQueryItem(name: "FOOD_NM_KR", value: foodName),
            ]
            components?.queryItems = queryItems
            
            guard let url = components?.url else {
                throw APIError.urlError
            }

            do {
                let response = await AF.request(url, method: .get)
                                      .serializingDecodable(FoodNutritionAPIResponse.self)
                                      .response
                
                switch response.result {
                case .success(let decodedResponse):
                    return decodedResponse
                case .failure(let afError):
                    if let underlyingError = afError.underlyingError as? DecodingError {
                        throw APIError.decodingError(String(describing: underlyingError))
                    } else if afError.responseCode != nil {
                        throw APIError.requestFailed("HTTP \(afError.responseCode ?? -1): \(afError.localizedDescription)")
                    } else {
                        throw APIError.requestFailed(afError.localizedDescription)
                    }
                }
            } catch let error as APIError {
                throw error
            } catch {
                throw APIError.unknownError
            }
        }
    )
}

private let apiServiceErrorDescriptions: [String: String] = [
    "1": "어플리케이션 에러가 발생했습니다.",
    "4": "HTTP 에러가 발생했습니다. 네트워크 상태를 확인하거나 잠시 후 다시 시도해주세요.",
    "12": "요청하신 오픈 API 서비스가 없거나 폐기되었습니다. 관리자에게 문의해주세요.",
    "20": "서비스 접근이 거부되었습니다. 권한을 확인해주세요.",
    "22": "서비스 요청 제한 횟수를 초과했습니다. 잠시 후 다시 시도해주세요.",
    "23": "최대 동시 요청 수를 초과했습니다. 잠시 후 다시 시도해주세요.",
    "30": "등록되지 않은 서비스 키입니다. 서비스 키를 확인해주세요.",
    "31": "서비스 활용 기간이 만료되었습니다.",
    "32": "등록되지 않은 IP 주소입니다. 허용된 IP인지 확인해주세요.",
    "99": "알 수 없는 서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
]

enum APIError: Error, Equatable, LocalizedError {
    case urlError
    case requestFailed(String)
    case decodingError(String)
    case noData
    case apiServiceError(resultCode: String, originalMsg: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .urlError:
            return "잘못된 URL 형식입니다."
        case .requestFailed(let msg):
            return "네트워크 요청에 실패했습니다: \(msg). 인터넷 연결을 확인해주세요."
        case .decodingError(let msg):
            return "데이터를 처리하는 중 오류가 발생했습니다: \(msg)."
        case .noData:
            return "요청하신 데이터가 존재하지 않습니다."
        case .apiServiceError(let code, let originalMsg):
            let knownDescription = apiServiceErrorDescriptions[code]
            if let description = knownDescription {
                return description
            } else if !originalMsg.isEmpty && originalMsg != "FAIL" {
                return "서버 오류 (코드: \(code)): \(originalMsg)"
            } else {
                return "알 수 없는 서버 오류가 발생했습니다 (코드: \(code))."
            }
        case .unknownError:
            return "알 수 없는 오류가 발생했습니다. 앱을 다시 시작하거나 나중에 시도해주세요."
        }
    }

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.urlError, .urlError): return true
        case (.requestFailed(let l), .requestFailed(let r)): return l == r
        case (.decodingError(let l), .decodingError(let r)): return l == r
        case (.noData, .noData): return true
        case (.apiServiceError(let lc, let lm), .apiServiceError(let rc, let rm)): return lc == rc && lm == rm
        case (.unknownError, .unknownError): return true
        default: return false
        }
    }
}

extension DependencyValues {
    var foodNutritionClient: FoodNutritionClient {
        get { self[FoodNutritionClient.self] }
        set { self[FoodNutritionClient.self] = newValue }
    }
}
