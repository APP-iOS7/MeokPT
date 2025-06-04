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
        
        case loadInfo
        
        case task
        case nutritionDataDidChangeNotification
        case dietDataDidChangeNotification
        
        case dietItemMealTypeChanged(id: DietItem.ID, mealType: MealType)

        case _internalLoadInfoCompleted([NutritionItem])
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
        case fetchFailed
    }
    
    enum FeatureCancelID: Hashable {
        case dataLoadListener
        case nutritionUpdateListener
        case dietUpdateListener
    }

    @Dependency(\.modelContainer) var modelContainer

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
                
            case .loadInfo:
                state.isLoading = true
                state.errorMessage = nil
                print("➡️ DailyNutritionDietInfoFeature: .loadInfo called. Will perform ASYNC fetch.")
                return .run { send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
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
                            send(._internalLoadInfoCompleted(sortedItems))
                        } catch {
                            print("DailyNutritionDietInfoFeature: Fetch failed after delay: \(error)")
                            send(._internalLoadInfoFailed(.fetchFailed))
                        }
                    }
                }
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
                
            case let .dietItemMealTypeChanged(id, newMealType):
                guard let index = state.dietItems?.firstIndex(where: { $0.id == id }) else {
                    print("Error: DietItem with ID \(id) not found.")
                    return .none
                }
                state.dietItems?[index].mealType = newMealType

                return .run { [modelContainer] send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            
                            let descriptor = FetchDescriptor<DietItem>(predicate: #Predicate {
                                $0.id == id
                            })
                            
                            if let dietItemToUpdate = try context.fetch(descriptor).first {
                                dietItemToUpdate.mealType = newMealType // fetched된 객체 수정
                                try context.save()
                                print("Successfully saved mealType change for DietItem \(id) to \(newMealType.rawValue)")
                            } else {
                                print("Error: DietItem with ID \(id) not found in context for update.")
                                Task {
                                    send(._internalLoadInfoFailed(.dietItemFetchFailed))
                                }
                            }
                        } catch {
                            print("Error saving DietItem mealType change: \(error)")
                            Task {
                                send(._internalLoadInfoFailed(.dietItemFetchFailed))
                            }
                        }
                    }
                }

            case .nutritionDataDidChangeNotification:
                print("DailyNutritionDietInfoFeature: received notification")
                state.lastDataChangeTimestamp = Date()
                return .none
                
            case .dietDataDidChangeNotification:
                 state.lastDataChangeTimestamp = Date()
                 return .none
            
            case let ._internalLoadInfoCompleted(items):
                state.isLoading = false
                state.nutritionItems = items
                print("Nutrition 최대값 로딩 성공 (after async processing)")
                return .none
                
            case let ._internalLoadInfoFailed(error):
                state.isLoading = false
                state.errorMessage = "Nutrition 정보 불러오기 실패 (async)"
                print("에러 (async loadInfo): \(error.localizedDescription)")
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
