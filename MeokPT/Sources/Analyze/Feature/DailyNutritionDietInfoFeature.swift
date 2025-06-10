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
            guard let nutritionItems = nutritionItems,
                  let dietItems = dietItems else { return false }
            return !nutritionItems.isEmpty && !dietItems.isEmpty
        }
        
        var showAlertToast = false
        var toastTitle = ""
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
        
        case clearAllDietItems
        case hideToast

        case _internalLoadInfoCompleted([NutritionItem], [DietItem])
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
                
            case .loadInfo:
                state.isLoading = true
                state.errorMessage = nil
                print("➡️ DailyNutritionDietInfoFeature: .loadInfo called. Will perform ASYNC fetch.")
                return .run { send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            let nutritionDescriptor = FetchDescriptor<NutritionItem>()
                            let nutritionItems = try context.fetch(nutritionDescriptor)
                            
                            let dietDescriptor = FetchDescriptor<DietItem>()
                            let dietItems = try context.fetch(dietDescriptor)
                                                        
                            print("Nutriitem 개수 (after delay): \(nutritionItems.count)")
                            let typeOrder = NutritionType.allCases
                            let sortedItems = nutritionItems.sorted {
                                guard let first = typeOrder.firstIndex(of: $0.type),
                                      let second = typeOrder.firstIndex(of: $1.type) else { return false }
                                return first < second
                            }
                            send(._internalLoadInfoCompleted(sortedItems, dietItems))
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
                                dietItemToUpdate.mealType = newMealType
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
            case .clearAllDietItems:
                state.isLoading = true
                state.showAlertToast = true
                state.toastTitle = "식단 비우기를 완료했습니다."
                return .run { send in
                    await MainActor.run {
                        let context = modelContainer.mainContext
                        do {
                            let dietDescriptor = FetchDescriptor<DietItem>()
                            let dietItems = try context.fetch(dietDescriptor)
                            for item in dietItems {
                                context.delete(item)
                            }
                            
                            let nutritionDescriptor = FetchDescriptor<NutritionItem>()
                            let nutritionItems = try context.fetch(nutritionDescriptor)
                            for item in nutritionItems {
                                item.value = 0
                            }
                            
                            try context.save()
                            print("모든 DietItem 삭제 성공 및 NutritionItems 초기화")
                            send(.loadInfo)
                        } catch {
                            print("DietItems 삭제 실패")
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
            
            case let ._internalLoadInfoCompleted(nutritionItems, dietItems):
                state.isLoading = false
                state.nutritionItems = nutritionItems
                state.dietItems = dietItems
                print("Nutrition 최대값 로딩 성공 (after async processing)")
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
            case .hideToast:
                state.showAlertToast = false
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
                
            case .dietSelectionSheetAction(.presented(.delegate(.dietSelected(_)))):
                print("Diets selected in sheet")
                state.dietSelectionSheet = nil
                return .send(.loadInfo)
                
            case .aiSheetAction(.dismiss):
                state.showAlertToast = true
                state.toastTitle = "분석 내용을 저장하였습니다."
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
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
