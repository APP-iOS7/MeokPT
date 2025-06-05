//
//  AddFoddFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/26/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AddFoodFeature {
    @ObservableState
    struct State: Equatable {
        
        var selectedFoodItem: FoodNutritionItem
        
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
        
        init(selectedFoodItem: FoodNutritionItem) {
            self.selectedFoodItem = selectedFoodItem
            let initialAmount = selectedFoodItem.servingSize > 0 ? Int(selectedFoodItem.servingSize) : 100
            self.amountGram = Double(initialAmount)
            
            // 100g당 영양 정보를 기준으로 초기 amountGram에 맞게 계산
            self.currentCalories = (selectedFoodItem.calorie / 100.0) * Double(initialAmount)
            self.currentCarbohydrates = selectedFoodItem.carbohydrate.map { ($0 / 100.0) * Double(initialAmount) }
            self.currentProtein = selectedFoodItem.protein.map { ($0 / 100.0) * Double(initialAmount) }
            self.currentFat = selectedFoodItem.fat.map { ($0 / 100.0) * Double(initialAmount) }
            self.currentDietaryFiber = selectedFoodItem.dietaryFiber.map { ($0 / 100.0) * Double(initialAmount) }
            self.currentSugar = selectedFoodItem.sugar.map { ($0 / 100.0) * Double(initialAmount) }
            self.currentSodium = selectedFoodItem.sodium.map { ($0 / 100.0) * Double(initialAmount) }
        }
        
        var info: AttributedString {
            let markdownString: String
            if selectedFoodItem.servingSize > 0 {
                markdownString = "식약처 DB에서 제공하는 총 내용량(1회 제공량)은 **\(Int(selectedFoodItem.servingSize))g** 입니다."
            } else {
                markdownString = "식약처 DB에서 총 내용량을 제공하지 않습니다. **100g** 기준으로 표시됩니다."
            }
            do {
                return try AttributedString(markdown: markdownString)
            } catch {
                return AttributedString(markdownString)
            }
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
        case addButtonTapped
        
        case delegate(DelegateAction)
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
        case addFoodToDiet(foodName: String, amount: Double, calories: Double, carbohydrates: Double?, protein: Double?, fat: Double?, dietaryFiber: Double?, sugar: Double?, sodium: Double?)
        case createToast(foodName: String, amount: Double)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.amountGram):
                // amountGram이 0 미만이 되지 않도록 보정
                if state.amountGram < 0 {
                    state.amountGram = 0
                }
                // amountGram 변경 시, selectedFoodItem의 100g당 비율을 기준으로 모든 영양소 재계산
                state.currentCalories = (state.selectedFoodItem.calorie / 100.0) * Double(state.amountGram)
                state.currentCarbohydrates = state.selectedFoodItem.carbohydrate.map { ($0 / 100.0) * Double(state.amountGram) }
                state.currentProtein = state.selectedFoodItem.protein.map { ($0 / 100.0) * Double(state.amountGram) }
                state.currentFat = state.selectedFoodItem.fat.map { ($0 / 100.0) * Double(state.amountGram) }
                state.currentDietaryFiber = state.selectedFoodItem.dietaryFiber.map { ($0 / 100.0) * Double(state.amountGram) }
                state.currentSugar = state.selectedFoodItem.sugar.map { ($0 / 100.0) * Double(state.amountGram) }
                state.currentSodium = state.selectedFoodItem.sodium.map { ($0 / 100.0) * Double(state.amountGram) }
                return .none

            case .binding(_):
                return .none
                
            case .cancelButtonTapped:
                return .run { send in await send(.delegate(.dismissSheet)) }

            case .addButtonTapped:
                guard state.amountGram > 0 else { return .none }
                
                return .run { [
                    foodName = state.selectedFoodItem.foodName,
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
