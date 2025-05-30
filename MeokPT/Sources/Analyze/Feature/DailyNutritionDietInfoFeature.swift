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
        
        var lastDataChangeTimestamp: Date = Date()
        
        var isAIbuttonEnabled: Bool {
            !(nutritionItems?.isEmpty ?? true)
        }
    }
    
    enum Action: Equatable {
        case dietSelectionSheetAction(PresentationAction<DietSelectionSheetFeature.Action>)
        case aiSheetAction(PresentationAction<AISheetFeature.Action>)
        
        case presentDietSelectionSheet
        case presentAISheet
        
        case loadInfo(ModelContext)
        
        case task
        case nutritionDataDidChangeNotification
        case dietDataDidChangeNotification
        
        case dietItemMealTypeChanged(id: DietItem.ID, mealType: MealType, context: ModelContext)
        
        case _internalLoadNutritionInfoCompleted([NutritionItem])
        case _internalLoadDietItemsCompleted([DietItem])
        case _internalLoadInfoFailed(DataFetchError)
        
        case myPageNavigationButtonTapped
        case delegate(DelegateAction)
    }
    
    enum DelegateAction {
        case navigateToMyPage
    }
    
    enum DataFetchError: Error, Equatable {
        case nutritionFetchFailed
        case dietItemFetchFailed
    }
    
    enum FeatureCancelID: Hashable {
        case dataLoadListener
        case nutritionUpdateListener
        case dietUpdateListener
    }


    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .presentDietSelectionSheet:
                state.dietSelectionSheet = DietSelectionSheetFeature.State()
                return .none
                
            case .presentAISheet:
                guard state.isAIbuttonEnabled else {
                    print("Error: AI button")
                    return .none
                }
                state.aiSheet = AISheetFeature.State()
                return .none

            case .dietSelectionSheetAction, .aiSheetAction:
                return .none
                
            case let .loadInfo(context):
                state.isLoading = true
                state.errorMessage = nil
                print("➡️ DailyNutritionDietInfoFeature: .loadInfo called. Will perform ASYNC fetch.")
                return .concatenate(
                    .run { send in
                    do {
                        let descriptor = FetchDescriptor<NutritionItem>()
                        let items = try context.fetch(descriptor)
                        
                        print("Nutriitem 개수 (after delay): \(items.count)")
                        for item in items {
                            print("  Fetched (after delay): \(item.type.rawValue) - Value: \(item.value)\(item.unit), Max: \(item.max)\(item.unit)")
                        }
                        
                        let typeOrder = NutritionType.allCases
                        let sortedItems = items.sorted {
                            guard let first = typeOrder.firstIndex(of: $0.type),
                                  let second = typeOrder.firstIndex(of: $1.type) else { return false }
                            return first < second
                        }
                        await send(._internalLoadNutritionInfoCompleted(sortedItems))
                    } catch {
                        print("DailyNutritionDietInfoFeature: Fetch failed after delay: \(error)")
                        await send(._internalLoadInfoFailed(.nutritionFetchFailed))
                    }
                },
                    .run { send in
                        do {
                            let sortDescriptor = [SortDescriptor(\DietItem.timestamp, order: .reverse)]
                            let descriptor = FetchDescriptor<DietItem>(sortBy: sortDescriptor)
                            let items = try context.fetch(descriptor)
                            print("DietItem count: \(items.count)")
                            await send(._internalLoadDietItemsCompleted(items))
                        } catch {
                            print("DailyNutritionDietInfoFeature: DietItem fetch Failed")
                            await send(._internalLoadInfoFailed(.dietItemFetchFailed))
                        }
                    }
                )
            case .task:
                print("DailyNutritionDietInfoFeature: .task action received, setting up listeners.")
                return .merge(
                    .run { send in
                        for await _ in NotificationCenter.default.notifications(named: .didUpdateNutritionItems) {
                            print("Notification received: .didUpdateNutritionItems")
                            await send(.nutritionDataDidChangeNotification)
                        }
                    }
                    .cancellable(id: FeatureCancelID.nutritionUpdateListener, cancelInFlight: true),

                    .run { send in
                        for await _ in NotificationCenter.default.notifications(named: .didUpdateDietItems) {
                            print("Notification received: .didUpdateDietItems")
                            await send(.dietDataDidChangeNotification)
                        }
                    }
                    .cancellable(id: FeatureCancelID.dietUpdateListener, cancelInFlight: true)
                )
                
            case let .dietItemMealTypeChanged(id, newMealType, context):
                guard let index = state.dietItems?.firstIndex(where: { $0.id == id }) else {
                    print("Error: DietItem with ID \(id) not found.")
                    return .none
                }
                state.dietItems?[index].mealType = newMealType
                
                do {
                    try context.save()
                    print("Successfully saved mealType change for DietItem \(id) to \(newMealType.rawValue)")
                } catch {
                    print("Error saving DietItem mealType change: \(error)")
                    state.errorMessage = "Failed to update meal type."
                }
                return .none

            case .nutritionDataDidChangeNotification:
                print("DailyNutritionDietInfoFeature: received notification")
                state.lastDataChangeTimestamp = Date()
                return .none
                
            case .dietDataDidChangeNotification:
                 state.lastDataChangeTimestamp = Date()
                 return .none
            
            case let ._internalLoadNutritionInfoCompleted(items):
                state.isLoading = false
                state.nutritionItems = items
                print("Nutrition 최대값 로딩 성공 (after async processing)")
                return .none
                
            case let ._internalLoadDietItemsCompleted(items):
                state.isLoading = false
                state.dietItems = items
                print("DietItems 로딩 성공")
                return .none
            case let ._internalLoadInfoFailed(error):
                state.isLoading = false
                state.errorMessage = "Nutrition 정보 불러오기 실패 (async)"
                switch error {
                case .nutritionFetchFailed:
                    state.errorMessage = "Nutrition Item Loaded Error"
                case .dietItemFetchFailed:
                    state.errorMessage = "Diet Item Loaded Error"
                }
                return .none
            case .myPageNavigationButtonTapped:
                return .send(.delegate(.navigateToMyPage))
            case .delegate(_):
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


