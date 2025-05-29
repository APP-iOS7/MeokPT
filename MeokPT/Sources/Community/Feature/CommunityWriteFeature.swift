import ComposableArchitecture
import Foundation

@Reducer
struct CommunityWriteFeature {
    @ObservableState
    struct State: Equatable {
        var title: String = ""
        var content: String = ""
        
        @Presents var mealSelectionSheet: MealSelectionFeature.State?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case mealSelectionAction(PresentationAction<MealSelectionFeature.Action>)
        case presentMealSelectionSheet
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .binding(_):
                return .none
            case .mealSelectionAction(_):
                return .none
            case .presentMealSelectionSheet:
                state.mealSelectionSheet = MealSelectionFeature.State()
                return .none
            }
        }
        .ifLet(\.$mealSelectionSheet, action: \.mealSelectionAction) {
            MealSelectionFeature()
        }
    }
}

