import ComposableArchitecture
import SwiftUI

// MARK: - API Constants
private enum APIConstants {
    static let serviceKey = "rG1rILvTxLQzzMdurCFALWpyOWZc6UKwB/e0ieF0erC7T3LUHQeXwowB4bvfoVBeEQrloeOmi4GMJBb8CLgw1w=="
    static let baseURL = "https://apis.data.go.kr/1471000/FoodNtrCpntDbInfo02/getFoodNtrCpntDbInq02"
}

// MARK: - Data Models
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

struct FoodNutritionItem: Decodable, Equatable, Identifiable {
    let ITEM_REPORT_NO: String?
    let FOOD_NM_KR: String?
    let DB_CLASS_NM: String?
    let AMT_NUM1: String?
    let AMT_NUM3: String?
    let AMT_NUM4: String?
    let AMT_NUM6: String?
    let AMT_NUM8: String?
    let AMT_NUM13: String?
    let Z10500: String?
    
    var id: String { ITEM_REPORT_NO ?? UUID().uuidString }
    
    var displayCalorie: String { (AMT_NUM1 ?? "N/A") + " kcal" }
    var displayProtein: String { (AMT_NUM3 ?? "N/A") + " g" }
    var displayFat: String { (AMT_NUM4 ?? "N/A") + " g" }
    var displayCarbohydrate: String { (AMT_NUM6 ?? "N/A") + " g" }
    var displayDietaryFiber: String { (AMT_NUM8 ?? "N/A") + " g" }
    var displaySodium: String { (AMT_NUM13 ?? "N/A") + " mg" }
    var displayServingSize: String { Z10500 ?? "N/A" }
}

// MARK: - API Client Dependency
struct FoodNutritionClient {
    var fetch: (_ foodName: String, _ dbClassName: String, _ pageNo: Int, _ numOfRows: Int, _ serviceKey: String) async throws -> FoodNutritionAPIResponse
}

extension FoodNutritionClient: DependencyKey {
    static let liveValue = Self(
        fetch: { foodName, dbClassName, pageNo, numOfRows, serviceKey in
            var components = URLComponents(string: APIConstants.baseURL)
            components?.queryItems = [
                URLQueryItem(name: "serviceKey", value: serviceKey),
                URLQueryItem(name: "pageNo", value: String(pageNo)),
                URLQueryItem(name: "numOfRows", value: String(numOfRows)),
                URLQueryItem(name: "type", value: "json"),
                URLQueryItem(name: "FOOD_NM_KR", value: foodName),
                URLQueryItem(name: "DB_CLASS_NM", value: dbClassName)
            ]
            
            guard let url = components?.url else {
                throw APIError.urlError
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                // HTTP 에러 코드를 포함하여 더 자세한 에러를 던질 수 있습니다.
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw APIError.requestFailed("HTTP \(statusCode)")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(FoodNutritionAPIResponse.self, from: data)
                return decodedResponse
            } catch let decodingError {
                // 디코딩 에러 시 실제 에러 내용을 포함하여 throw
                throw APIError.decodingError(String(describing: decodingError))
            }
        }
    )
}

extension DependencyValues {
    var foodNutritionClient: FoodNutritionClient {
        get { self[FoodNutritionClient.self] }
        set { self[FoodNutritionClient.self] = newValue }
    }
}

// API 에러 타입
enum APIError: Error, Equatable, LocalizedError {
    case urlError
    case requestFailed(String)
    case decodingError(String)
    case noData
    case apiError(resultCode: String, resultMsg: String)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .urlError: return "잘못된 URL입니다."
        case .requestFailed(let msg): return "네트워크 요청 실패: \(msg)"
        case .decodingError(let msg): return "데이터 파싱 실패: \(msg)"
        case .noData: return "데이터가 없습니다."
        case .apiError(let code, let msg): return "API 오류: 코드 \(code), 메시지 \(msg)"
        case .unknownError: return "알 수 없는 오류가 발생했습니다."
        }
    }
}


// MARK: - TCA Reducer
@Reducer
struct FoodNutritionFeature {
    @ObservableState
    struct State: Equatable {
        var foodNameInput: String = "고구마"
        var dbClassNameInput: String = "품목대표"
        var pageNo: Int = 1
        var numOfRows: Int = 1
        
        var fetchedFoodInfo: FoodNutritionItem?
        var isLoading: Bool = false
    }
    
    enum Action {
        case foodNameInputChanged(String)
        case dbClassNameInputChanged(String)
        case fetchButtonTapped
        case foodNutritionResponse(Result<FoodNutritionAPIResponse, Error>)
    }
    
    @Dependency(\.foodNutritionClient) var apiClient
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .foodNameInputChanged(let name):
                state.foodNameInput = name
                return .none
                
            case .dbClassNameInputChanged(let className):
                state.dbClassNameInput = className
                return .none
                
            case .fetchButtonTapped:
                guard !state.foodNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return .none
                }
                state.isLoading = true
                state.fetchedFoodInfo = nil
                
                return .run { [foodName = state.foodNameInput, dbClassName = state.dbClassNameInput, pageNo = state.pageNo, numOfRows = state.numOfRows] send in
                    let result = await Result {
                        try await apiClient.fetch(foodName, dbClassName, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result.mapError { $0 as Error })) // 일반 Error로 전달
                }
                
            case .foodNutritionResponse(.success(let response)):
                state.isLoading = false
                if response.header.resultCode == "00" {
                    if let item = response.body?.items?.first {
                        state.fetchedFoodInfo = item
                    } else {
                        state.fetchedFoodInfo = nil
                    }
                }
                return .none
                
            case .foodNutritionResponse(.failure(let error)):
                state.isLoading = false
                let apiError: APIError
                if let castedError = error as? APIError {
                    apiError = castedError
                } else {
                    apiError = .unknownError // 혹은 error.localizedDescription을 사용한 일반 에러 메시지
                }
                print(apiError)
                return .none
            }
        }
    }
}
