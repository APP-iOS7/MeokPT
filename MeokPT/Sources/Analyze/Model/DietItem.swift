import Foundation

struct DietItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let nutritions: [NutritionItem]
}
