import Foundation

struct NutritionItem: Identifiable, Equatable {    
    let id = UUID()
    let name: String
    let value: Int
    let unit: String
    let max: Int
}

let mockNutritionItems: [NutritionItem] = [
    NutritionItem(name: "열량", value: 2100, unit: "kcal", max: 2000),
    NutritionItem(name: "탄수화물", value: 20, unit: "g", max: 100),
    NutritionItem(name: "단백질", value: 10, unit: "g", max: 56),
    NutritionItem(name: "지방", value: 5, unit: "g", max: 35),
    NutritionItem(name: "식이섬유", value: 3, unit: "g", max: 28),
    NutritionItem(name: "당류", value: 8, unit: "g", max: 20),
    NutritionItem(name: "나트륨", value: 200, unit: "mg", max: 2000)
]
