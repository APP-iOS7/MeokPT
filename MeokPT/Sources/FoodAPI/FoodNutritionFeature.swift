import ComposableArchitecture
import SwiftUI
import Alamofire

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
        case searchButtonTapped
        case foodNutritionResponse(Result<FoodNutritionAPIResponse, Error>)
    }
    
    @Dependency(\.foodNutritionClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .foodNameInputChanged(let name):
                state.foodNameInput = name
                return .none
                
            case .dbClassNameInputChanged(let className):
                state.dbClassNameInput = className
                return .none
                
            case .searchButtonTapped:
                guard !state.foodNameInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    print("Food name is empty.")
                    return .none
                }
                state.isLoading = true
                state.fetchedFoodInfo = nil
                
                return .run { [foodName = state.foodNameInput, dbClassName = state.dbClassNameInput, pageNo = state.pageNo, numOfRows = state.numOfRows] send in
                    let result: Result<FoodNutritionAPIResponse, Error> = await Result {
                        try await apiClient.fetch(foodName, dbClassName, pageNo, numOfRows, APIConstants.serviceKey)
                    }
                    await send(.foodNutritionResponse(result))
                }
                
            case .foodNutritionResponse(.success(let response)):
                state.isLoading = false
                if response.header.resultCode == "00" {
                    if let item = response.body?.items?.first {
                        state.fetchedFoodInfo = item
                    } else {
                        state.fetchedFoodInfo = nil
                        print(APIError.noData.localizedDescription)
                    }
                } else {
                    let serviceError = APIError.apiServiceError(resultCode: response.header.resultCode, originalMsg: response.header.resultMsg)
                    print("API Service Error: \(serviceError.localizedDescription)")
                }
                return .none
                
            case .foodNutritionResponse(.failure(let error)):
                state.isLoading = false
                
                if error is CancellationError {
                    print("Request was cancelled.")
                    return .none
                }

                let errorToReport: APIError
                if let castedError = error as? APIError {
                    errorToReport = castedError
                } else {
                    errorToReport = .requestFailed(error.localizedDescription)
                }
                print("An error occurred: \(errorToReport.localizedDescription)")
                return .none
            }
        }
    }
}
