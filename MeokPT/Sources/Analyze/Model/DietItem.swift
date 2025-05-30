import SwiftData
import Foundation

@Model
final class DietItem: Identifiable {
    @Attribute(.unique) var id: UUID
    public var timestampe: Date
    public var name: String
    public var mealType: String
    
    public var kcal: Double
    public var carbohydrate: Double
    public var protein: Double
    public var fat: Double
    public var dietaryFiber: Double
    public var sugar: Double
    public var sodium: Double
    public var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        timestampe: Date = Date(),
        name: String,
        mealType: String,
        kcal: Double = 0.0,
        carbohydrate: Double = 0.0,
        protein: Double = 0.0,
        fat: Double = 0.0,
        dietaryFiber: Double = 0.0,
        sugar: Double = 0.0,
        sodium: Double = 0.0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.timestampe = timestampe
        self.name = name
        self.mealType = mealType
        self.kcal = kcal
        self.carbohydrate = carbohydrate
        self.protein = protein
        self.fat = fat
        self.dietaryFiber = dietaryFiber
        self.sugar = sugar
        self.sodium = sodium
        self.isFavorite = isFavorite
    }
}
