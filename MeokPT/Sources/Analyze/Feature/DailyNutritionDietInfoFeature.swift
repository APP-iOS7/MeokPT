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
        
        case toDietSelectionModalViewAction
        case dietSelectionDelegate(DelegateAction)
        
        case toAIModalViewAction
        case AIModalDelegate(DelegateAction)
    }
    
    enum DelegateAction {
        case toDietSelectionModalView
        case toAIModalView
    }
    
    enum NutritionError: Error, Equatable {
        case fetchFailed
    }

    @Dependency(\.fetchNutrition) var fetchNutrition

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let result = await fetchNutrition()
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
            case .toDietSelectionModalViewAction:
                return .send(.dietSelectionDelegate(.toDietSelectionModalView))
            case .dietSelectionDelegate(_):
                return .none
            case .toAIModalViewAction:
                return .send(.AIModalDelegate(.toAIModalView))
            case .AIModalDelegate(_):
                return .none
            }
        }
    }
}

enum FetchNutritionKey: DependencyKey {
    static let liveValue: () async -> Result<[NutritionItem]?, DailyNutritionDietInfoFeature.NutritionError> = {
        // 실제 구현
        .failure(.fetchFailed) // 예시
    }

    static let testValue: () async -> Result<[NutritionItem]?, DailyNutritionDietInfoFeature.NutritionError> = {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return .success(mockNutritionItems)
    }
}

extension DependencyValues {
    var fetchNutrition: () async -> Result<[NutritionItem]?, DailyNutritionDietInfoFeature.NutritionError> {
        get { self[FetchNutritionKey.self] }
        set { self[FetchNutritionKey.self] = newValue }
    }
}

