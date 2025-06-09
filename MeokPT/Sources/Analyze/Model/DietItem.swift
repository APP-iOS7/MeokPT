import SwiftData
import Foundation

@Model
final class DietItem: Identifiable, Equatable {
    var id: UUID
    var timestamp: Date
    var name: String
    var mealTypeRawValue: String
    
    var kcal: Double?
    var carbohydrate: Double?
    var protein: Double?
    var fat: Double?
    var dietaryFiber: Double?
    var sugar: Double?
    var sodium: Double?
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        name: String,
        mealTypeRawValue: String,
        kcal: Double?,
        carbohydrate: Double?,
        protein: Double?,
        fat: Double?,
        dietaryFiber: Double?,
        sugar: Double?,
        sodium: Double?,
        isFavorite: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.name = name
        self.mealTypeRawValue = mealTypeRawValue
        self.kcal = kcal
        self.carbohydrate = carbohydrate
        self.protein = protein
        self.fat = fat
        self.dietaryFiber = dietaryFiber
        self.sugar = sugar
        self.sodium = sodium
        self.isFavorite = isFavorite
    }
    
    var mealType: MealType? {
        get { MealType(rawValue: self.mealTypeRawValue) }
        set { self.mealTypeRawValue = newValue?.rawValue ?? ""}
    }
}

extension DietItem {
    func nutrientValue(for type: NutritionType) -> Double? {
        switch type {
        case .calorie: return self.kcal
        case .carbohydrate: return self.carbohydrate
        case .protein: return self.protein
        case .fat: return self.fat
        case .dietaryFiber: return self.dietaryFiber
        case .sugar: return self.sugar
        case .sodium: return self.sodium
        }
    }
    
    static func fromDiet(_ diet: Diet) -> DietItem {
        return DietItem(name: diet.title,
                        mealTypeRawValue: MealType.none.rawValue,
                        kcal: diet.kcal,
                        carbohydrate: diet.carbohydrate ?? nil,
                        protein: diet.protein ?? nil,
                        fat: diet.fat ?? nil,
                        dietaryFiber: diet.dietaryFiber ?? nil,
                        sugar: diet.sugar ?? nil,
                        sodium: diet.sodium ?? nil,
                        isFavorite: diet.isFavorite
        )
    }
}

extension DietItem {
    func formattedNutrientSafe(for type: NutritionType) -> String {
        guard let value = nutrientValue(for: type), !value.isNaN else {
                   return type == .calorie ? "---" : "--.-"
               }

               let formatter = NumberFormatter()
               formatter.numberStyle = .decimal
               formatter.minimumFractionDigits = 0
               formatter.maximumFractionDigits = (type == .calorie || type == .sodium) ? 0 : 1

               let formatted = formatter.string(from: NSNumber(value: value)) ?? (type == .calorie ? "---" : "--.-")
               return "\(formatted) \(type.unit)"
    }

    var formattedKcalOnlySafe: String {
            guard let value = self.kcal, !value.isNaN else { return "---" }

            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return "\(formatter.string(from: NSNumber(value: value)) ?? "---") \(NutritionType.calorie.unit)"
    }
}


let mockDietItemsForPreview = [
        DietItem(
            timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            name: "오트밀과 블루베리",
            mealTypeRawValue: MealType.breakfast.rawValue,
            kcal: 350, carbohydrate: 55.0, protein: 15.0, fat: 8.0,
            dietaryFiber: 10.0, sugar: 12.0, sodium: 150, isFavorite: false
        ),
        DietItem(
            timestamp: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
            name: "그릴드 치킨 샐러드",
            mealTypeRawValue: MealType.lunch.rawValue,
            kcal: 480, carbohydrate: 25.5, protein: 45.8, fat: 20.2,
            dietaryFiber: 8.5, sugar: 5.0, sodium: 300, isFavorite: true
        ),
        DietItem(
            timestamp: Calendar.current.date(byAdding: .minute, value: -120, to: Date())!,
            name: "연어와 아스파라거스",
            mealTypeRawValue: MealType.dinner.rawValue,
            kcal: 620, carbohydrate: 30.0, protein: 50.1, fat: 30.5,
            dietaryFiber: 7.0, sugar: 6.2, sodium: 250, isFavorite: false
        ),
        DietItem(
            timestamp: Date(), 
            name: "아몬드와 요거트",
            mealTypeRawValue: MealType.snack.rawValue,
            kcal: 180, carbohydrate: 10.0, protein: 7.0, fat: 14.0,
            dietaryFiber: 3.0, sugar: 2.0, sodium: 5, isFavorite: true
        )
    ]
