import Foundation
import ComposableArchitecture

struct Food: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let name: String
    var amount: Double
    var kcal: Double
    var carbohydrate: Double?
    var protein: Double?
    var fat: Double?
    var dietaryFiber: Double?
    var sodium: Double?
    var sugar: Double?
}

@ObservableState
struct Diet: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    var title: String
    var isFavorite: Bool
    var foods: [Food]

    var kcal: Double {
        foods.reduce(0) { $0 + max(0, $1.kcal) }
    }
    
    var carbohydrate: Double? {
        let validValues = foods.compactMap { $0.carbohydrate }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
    
    var protein: Double? {
        let validValues = foods.compactMap { $0.protein }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
    
    var fat: Double? {
        let validValues = foods.compactMap { $0.fat }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
    
    var dietaryFiber: Double? {
        let validValues = foods.compactMap { $0.dietaryFiber }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
    
    var sodium: Double? {
        let validValues = foods.compactMap { $0.sodium }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
    
    var sugar: Double? {
        let validValues = foods.compactMap { $0.sugar }
        return validValues.isEmpty ? nil : validValues.reduce(0) {$0 + $1}
    }
}
