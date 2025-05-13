import ComposableArchitecture
import Foundation

@Reducer
struct DailyNutritionDietInfoFeature {
    @ObservableState
    struct State: Equatable {
        var nutritionItems: [NutritionItem]?
        var dietItems: [DietItem]?
        
        var isLoading = false
        var errorMessage: String?
    }
    
    enum Action: Equatable {
        case onAppear
        case nutritionResponse(Result<[NutritionItem]?, NutritionError>)
        case DietSelectionViewAction
        case delegate(DelegateAction)
    }
    
    enum DelegateAction {
        case DietSelectionView
    }
    
    enum NutritionError: Error, Equatable {
        case fetchFailed
    }

    struct NutritionEnvironment {
        var fetchNutrition: () async -> Result<[NutritionItem]?, NutritionError>
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
                    state.nutritionItems = nutrition
                    state.errorMessage = nil
                case .failure:
                    state.nutritionItems = nil
                    state.errorMessage = "개인 맞춤 영양성분을 불러올 수 없습니다."
                }
                return .none
            case .DietSelectionViewAction:
                return .send(.delegate(.DietSelectionView))
            case .delegate(_):
                return .none
            }
        }
    }
}

// MARK: - Mock 비동기 구현
extension DailyNutritionDietInfoFeature.NutritionEnvironment {
    static let mock = Self(
        fetchNutrition: {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return .success(
                mockNutritionItems
            )
        }
    )
}
