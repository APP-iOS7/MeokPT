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
        
        @Presents var dietSelectionSheet: DietSelectionSheetFeature.State?
        @Presents var aiSheet: AISheetFeature.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case nutritionResponse(Result<[NutritionItem]?, NutritionError>)
        
        case dietSelectionSheetAction(PresentationAction<DietSelectionSheetFeature.Action>)
        case aiSheetAction(PresentationAction<AISheetFeature.Action>)
        
        case presentDietSelectionSheet
        case presentAISheet
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
                
            case .presentDietSelectionSheet:
                state.dietSelectionSheet = DietSelectionSheetFeature.State()
                return .none
                
            case .presentAISheet:
                state.aiSheet = AISheetFeature.State()
                return .none

            case .dietSelectionSheetAction, .aiSheetAction:
                return .none
            }
        }
        .ifLet(\.$dietSelectionSheet, action: \.dietSelectionSheetAction) {
            DietSelectionSheetFeature()
        }
        .ifLet(\.$aiSheet, action: \.aiSheetAction) {
            AISheetFeature()
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

