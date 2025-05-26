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
        var amountGram: Int
        let maxInputLength = 4
        
        // 초기화 시점에 selectedFoodItem을 받아 amountGram을 설정
        init(selectedFoodItem: FoodNutritionItem) {
            self.selectedFoodItem = selectedFoodItem
            // servingSize가 0보다 크면 그 값을, 아니면 기본값 100을 사용
            self.amountGram = selectedFoodItem.servingSize > 0 ? Int(selectedFoodItem.servingSize) : 100
        }
        
        var currentCalories: Double {
            (selectedFoodItem.calorie / 100.0) * Double(amountGram)
        }
        var currentCarbohydrates: Double {
            (selectedFoodItem.carbohydrate / 100.0) * Double(amountGram)
        }
        var currentProtein: Double {
            (selectedFoodItem.protein / 100.0) * Double(amountGram)
        }
        var currentFat: Double {
            (selectedFoodItem.fat / 100.0) * Double(amountGram)
        }
        var info: AttributedString? {
            let markdownString: String
            if selectedFoodItem.servingSize > 0 {
                markdownString = "식약처 DB에서 제공하는 총 내용량은 **\(Int(selectedFoodItem.servingSize))g**입니다."
            } else {
                markdownString = "총 내용량을 식약처 DB에서 제공하지 않아 **100g** 기준으로 표시됩니다."
            }
            return try? AttributedString(markdown: markdownString)
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
        case addFoodToDiet(FoodNutritionItem, Int) // 추가될 음식과 양
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
                return .none
                
            case .binding(_):
                return .none
                
            case .cancelButtonTapped:
                return .run { send in await send(.delegate(.dismissSheet)) }

            case .addButtonTapped:
                // TODO: 실제 식단에 추가하는 로직 (예: Delegate 통해 전달)
                guard state.amountGram > 0 else { return .none } // 0g 이하면 추가하지 않음
                return .run { [foodItem = state.selectedFoodItem, amount = state.amountGram] send in
                    await send(.delegate(.addFoodToDiet(foodItem, amount)))
                    await send(.delegate(.dismissSheet))
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
