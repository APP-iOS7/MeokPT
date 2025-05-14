import Foundation

struct NutritionItem: Identifiable, Equatable {    
    let type: NutritionType
    var value: Int
    var max: Int
    
    var id: String { type.id }
    var name: String { type.rawValue }
    var unit: String { type.unit }
}

let mockNutritionItems: [NutritionItem] = [
    NutritionItem(type: .calorie, value: 2100, max: 2000),
    NutritionItem(type: .carbohydrate, value: 20, max: 100),
    NutritionItem(type: .protein, value: 10, max: 56),
    NutritionItem(type: .fat, value: 5, max: 35),
    NutritionItem(type: .dietaryFiber, value: 3, max: 28),
    NutritionItem(type: .sugar, value: 8, max: 20),
    NutritionItem(type: .sodium, value: 200, max: 2000),
]
