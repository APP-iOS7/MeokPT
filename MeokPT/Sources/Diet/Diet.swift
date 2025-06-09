import Foundation
import ComposableArchitecture
import SwiftData

@Model
final class Food: Identifiable, Equatable, Hashable {
    @Attribute(.unique) var id: UUID
    var name: String
    var creationDate: Date = Date()
    var amount: Double
    var kcal: Double
    var carbohydrate: Double?
    var protein: Double?
    var fat: Double?
    var dietaryFiber: Double?
    var sodium: Double?
    var sugar: Double?
    
    init(id: UUID = UUID(), name: String, amount: Double, kcal: Double, carbohydrate: Double? = nil, protein: Double? = nil, fat: Double? = nil, dietaryFiber: Double? = nil, sodium: Double? = nil, sugar: Double? = nil) {
        self.id = id
        self.name = name
        self.amount = amount
        self.kcal = kcal
        self.carbohydrate = carbohydrate
        self.protein = protein
        self.fat = fat
        self.dietaryFiber = dietaryFiber
        self.sodium = sodium
        self.sugar = sugar
    }
}

@Model
final class Diet: Identifiable, Equatable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var creationDate: Date = Date()
    var isFavorite: Bool
    var foods: [Food]
    
    init(id: UUID = UUID(), title: String, isFavorite: Bool, foods: [Food]) {
        self.id = id
        self.title = title
        self.isFavorite = isFavorite
        self.foods = foods
    }

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
