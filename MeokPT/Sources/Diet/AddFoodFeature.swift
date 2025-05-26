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
            guard selectedFoodItem.servingSize > 0 else { // 100g 기준 영양 정보 사용
                return (selectedFoodItem.calorie / 100.0) * Double(amountGram)
            }
            // servingSize가 있다면, 1g당 영양정보를 계산하여 현재 g에 맞게 계산
            return (selectedFoodItem.calorie / selectedFoodItem.servingSize) * Double(amountGram)
        }
        var currentCarbohydrates: Double {
            guard selectedFoodItem.servingSize > 0 else {
                return (selectedFoodItem.carbohydrate / 100.0) * Double(amountGram)
            }
            return (selectedFoodItem.carbohydrate / selectedFoodItem.servingSize) * Double(amountGram)
        }
        var currentProtein: Double {
            guard selectedFoodItem.servingSize > 0 else {
                return (selectedFoodItem.protein / 100.0) * Double(amountGram)
            }
            return (selectedFoodItem.protein / selectedFoodItem.servingSize) * Double(amountGram)
        }
        var currentFat: Double {
            guard selectedFoodItem.servingSize > 0 else {
                return (selectedFoodItem.fat / 100.0) * Double(amountGram)
            }
            return (selectedFoodItem.fat / selectedFoodItem.servingSize) * Double(amountGram)
        }
        var info: AttributedString? {
            _ = selectedFoodItem.servingSize > 0 ? "\(Int(selectedFoodItem.servingSize))g" : "제공량 정보 없음 (100g 기준 영양 정보)"
            // FoodNutritionItem의 foodName은 옵셔널이 아니라고 가정 (FoodNutritionItem.swift에서 non-optional로 처리됨)
            let foodName = selectedFoodItem.foodName
            let servingInfoText = selectedFoodItem.servingSize > 0 ? "\(Int(selectedFoodItem.servingSize))g" : "100g"

            // CreateDietView에서 "영양성분은 100g 기준입니다." 라고 명시되어 있으므로,
            // API에서 제공하는AMT_NUM 값들이 100g 기준 값이라고 간주.
            // Z10500 (servingSize)는 별도의 "총 내용량" 정보로 활용.
            let markdownString = "\(foodName)의 총 내용량은 **\(servingInfoText)** 이며,\n 아래 영양성분은 입력하신 **\(amountGram)g** 기준입니다."
            
//            if selectedFoodItem.servingSize == 0 {
//                 // servingSize가 0일때는 foodNameCorrections에 있는 foodName을 사용하도록 처리
//                let adjustedFoodName = foodNameCorrections[selectedFoodItem.FOOD_NM_KR ?? ""] ?? selectedFoodItem.foodName
//                let markdownStringZeroServing = "\(adjustedFoodName)의 영양성분은 100g 기준이며, 아래는 입력하신 **\(amountGram)g** 기준입니다."
//                 return try? AttributedString(markdown: markdownStringZeroServing)
//            }


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
