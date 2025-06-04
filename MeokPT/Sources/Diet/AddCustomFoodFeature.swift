//
//  AddCustomFoodFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/26/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddCustomFoodFeature {
    @ObservableState
    struct State: Equatable {
                
        let cornerRadius: CGFloat = 20
        var amountGram: Double?
        let maxInputLength = 4
        
        var foodName: String
        var currentCalories: Double?
        var currentCarbohydrates: Double?
        var currentProtein: Double?
        var currentFat: Double?
        var currentDietaryFiber: Double?
        var currentSugar: Double?
        var currentSodium: Double?
        
        var checkNameAmount: Bool {
            !foodName.isEmpty && (amountGram ?? 0) != 0
        }
        
        init() {
            self.foodName = ""
            self.currentCalories = 0
            self.currentCarbohydrates = 0
            self.currentProtein = 0
            self.currentFat = 0
            self.currentDietaryFiber = 0
            self.currentSugar = 0
            self.currentSodium = 0
        }
    }
        
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case cancelButtonTapped
        case addButtonTapped
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
        case addFoodToDiet(foodName: String, amount: Double?, calories: Double?, carbohydrates: Double?, protein: Double?, fat: Double?, dietaryFiber: Double?, sugar: Double?, sodium: Double?)
        case createToast(foodName: String, amount: Double?)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case .cancelButtonTapped:
                return .run { send in await send(.delegate(.dismissSheet)) }

            case .addButtonTapped:                
                return .run { [
                    foodName = state.foodName,
                    amount = state.amountGram,
                    calories = state.currentCalories,
                    carbs = state.currentCarbohydrates,
                    protein = state.currentProtein,
                    fat = state.currentFat,
                    dietaryFiber = state.currentDietaryFiber,
                    sugar = state.currentSugar,
                    sodium = state.currentSodium
                ] send in
                    await send(.delegate(.addFoodToDiet(foodName: foodName, amount: amount, calories: calories, carbohydrates: carbs, protein: protein, fat: fat, dietaryFiber: dietaryFiber, sugar: sugar, sodium: sodium)))
                    await send(.delegate(.createToast(foodName: foodName, amount: amount)))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
