import ComposableArchitecture
import SwiftData
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
        case dietSelectionSheetAction(PresentationAction<DietSelectionSheetFeature.Action>)
        case aiSheetAction(PresentationAction<AISheetFeature.Action>)
        
        case presentDietSelectionSheet
        case presentAISheet
        
        case loadInfo(ModelContext)
    }
    
    enum NutritionError: Error, Equatable {
        case fetchFailed
    }


    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
        
            case .presentDietSelectionSheet:
                state.dietSelectionSheet = DietSelectionSheetFeature.State()
                return .none
                
            case .presentAISheet:
                state.aiSheet = AISheetFeature.State()
                return .none

            case .dietSelectionSheetAction, .aiSheetAction:
                return .none
                
            case let .loadInfo(context):
                do {
                    let items = try context.fetch(FetchDescriptor<NutritionItem>())
                    
                    print("Nutriitem 개수: \(items.count)")
                    
                    for item in items {
                        print("로드 : \(item.type.rawValue) - \(item.value)\(item.unit)")
                    }
                    
                    let typeOrder = NutritionType.allCases
                    let sorted = items.sorted {
                        guard let first = typeOrder.firstIndex(of: $0.type),
                              let second = typeOrder.firstIndex(of: $1.type) else {
                            return false
                        }
                        return first < second
                    }
                    state.nutritionItems = sorted
                    print("Nutrition 최대값 로딩 성공")
                } catch {
                    state.errorMessage = "Nutrition 정보 불러오기 실패"
                    print("에러: \(error.localizedDescription)")
                }
                state.isLoading = false
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


