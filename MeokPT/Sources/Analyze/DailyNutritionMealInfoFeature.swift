import ComposableArchitecture
import Foundation

@Reducer
struct DailyNutritionMealInfoFeature {
    @ObservableState
    struct State: Equatable {
        var dailyNubrition: DailyNutrition?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    enum Action: Equatable {
        case onAppear
        case nutritionResponse(Result<DailyNutrition?, NutritionError>)
    }
    
    enum NutritionError: Error, Equatable {
        case fetchFailed
    }

    struct NutritionEnvironment {
        var fetchNutrition: () async -> Result<DailyNutrition?, NutritionError>
    }
    
    var environment: NutritionEnvironment

    var body: some ReducerOf<Self> {

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [environment] send in
                    let result = await environment.fetchNutrition()
                    await send(.nutritionResponse(result))
                }
            case let .nutritionResponse(result):
                state.isLoading = false
                switch result {
                case let .success(nutrition):
                    state.dailyNubrition = nutrition
                    state.errorMessage = nil
                case .failure:
                    state.dailyNubrition = nil
                    state.errorMessage = "개인 맞춤 영양성분을 불러올 수 없습니다."
                }
                return .none
            }
        }
    }
}

extension DailyNutritionMealInfoFeature.NutritionEnvironment {
    // 하루 영양 정보 목업 (실제 비동기 흐름 모사)
    static let mock = Self(
        fetchNutrition: {
            // 1초 지연 후 목 데이터 반환
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return .success(
                DailyNutrition(calories: 2000, carbohydrate: 100, protein: 56, fat: 35, dietaryFiber: 28, sugar: 20, sodium: 2000)
            )
        }
    )
}
