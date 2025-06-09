import Foundation
import ComposableArchitecture

@Reducer
struct EditFoodFeature {
    @ObservableState
    struct State: Equatable {
        var food: Food
        var originalFood: Food
        
        let cornerRadius: CGFloat = 20
        var amountGram: Double
        let maxInputLength = 4
        
        var currentCalories: Double
        var currentCarbohydrates: Double?
        var currentProtein: Double?
        var currentFat: Double?
        var currentDietaryFiber: Double?
        var currentSugar: Double?
        var currentSodium: Double?
        
        init(food: Food) {
            self.food = food
            self.originalFood = food
            self.amountGram = food.amount
            
            self.currentCalories = food.kcal
            self.currentCarbohydrates = food.carbohydrate
            self.currentProtein = food.protein
            self.currentFat = food.fat
            self.currentDietaryFiber = food.dietaryFiber
            self.currentSugar = food.sugar
            self.currentSodium = food.sodium
        }
        
        var isCarbohydratesAvailable: Bool { currentCarbohydrates != nil }
        var isProteinAvailable: Bool { currentProtein != nil }
        var isFatAvailable: Bool { currentFat != nil }
        var isDietaryFiberAvailable: Bool { currentDietaryFiber != nil }
        var isSugarAvailable: Bool { currentSugar != nil }
        var isSodiumAvailable: Bool { currentSodium != nil }
        
        var isNutrientEmpty: Bool {
            currentCarbohydrates == nil || currentProtein == nil || currentFat == nil ||
            currentDietaryFiber == nil || currentSugar == nil || currentSodium == nil
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cancelButtonTapped
        case saveButtonTapped
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.amountGram):
                // 원본 음식 데이터를 기준으로 비율 계산
                let ratio = state.amountGram / state.originalFood.amount
                
                state.currentCalories = state.originalFood.kcal * ratio
                state.currentCarbohydrates = state.originalFood.carbohydrate.map { $0 * ratio }
                state.currentProtein = state.originalFood.protein.map { $0 * ratio }
                state.currentFat = state.originalFood.fat.map { $0 * ratio }
                state.currentDietaryFiber = state.originalFood.dietaryFiber.map { $0 * ratio }
                state.currentSugar = state.originalFood.sugar.map { $0 * ratio }
                state.currentSodium = state.originalFood.sodium.map { $0 * ratio }
                return .none

            case .binding(_):
                return .none
                
            case .cancelButtonTapped:
                return .run { send in await send(.delegate(.dismissSheet)) }

            case .saveButtonTapped:
                guard state.amountGram > 0 else { return .none }
                
                // Food 객체의 속성을 직접 업데이트
                state.food.amount = state.amountGram
                state.food.kcal = state.currentCalories
                state.food.carbohydrate = state.currentCarbohydrates
                state.food.protein = state.currentProtein
                state.food.fat = state.currentFat
                state.food.dietaryFiber = state.currentDietaryFiber
                state.food.sodium = state.currentSodium
                state.food.sugar = state.currentSugar
                
                return .run { send in
                    await send(.delegate(.dismissSheet))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
