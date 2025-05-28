import Foundation

struct NutritionAnalysisInputForJSON: Codable {
    let userProfile: UserProfileForJSON
    let meals: [MealForJSON]
}

struct DailyIntakeForJSON: Codable {
    let calories: Int
    let carbohydrates: Int
    let protein: Int
    let fat: Int
    let dietaryFiber: Int
    let sugar: Int
    let sodium: Int
}

struct UserProfileForJSON: Codable {
    let dailyRecommendedIntake: DailyIntakeForJSON
}

struct MealForJSON: Codable {
    let mealType: String
    let calories: Int
    let carbohydrates: Int
    let protein: Int
    let fat: Int
    let dietaryFiber: Int
    let sugar: Int
    let sodium: Int
}

func createNutritionInputForJSON(userRecommendedIntakeItems: [NutritionItem], consumedDiets: [Diet]) -> NutritionAnalysisInputForJSON? {
    var dailyCalories = 0
    var dailyCarbs = 0
    var dailyProtein = 0
    var dailyFat = 0
    var dailyFiber = 0
    var dailySugar = 0
    var dailySodium = 0
    
    for item in userRecommendedIntakeItems {
        switch item.type {
        case .calorie: dailyCalories = item.max
        case .carbohydrate: dailyCarbs = item.max
        case .protein: dailyProtein = item.max
        case .fat: dailyFat = item.max
        case .dietaryFiber: dailyFiber = item.max
        case .sugar: dailySugar = item.max
        case .sodium: dailySodium = item.max
        }
    }
    
    let dailyIntake = DailyIntakeForJSON(
        calories: dailyCalories,
        carbohydrates: dailyCarbs,
        protein: dailyProtein,
        fat: dailyFat,
        dietaryFiber: dailyFiber,
        sugar: dailySugar,
        sodium: dailySodium
    )
    
    let userProfile = UserProfileForJSON(dailyRecommendedIntake: dailyIntake)
    
    let mealsForJSON: [MealForJSON] = consumedDiets.map { diet in
        MealForJSON(
            mealType: diet.mealType,
            calories: Int(diet.kcal.rounded()),
            carbohydrates: Int(diet.carbohydrate.rounded()),
            protein: Int(diet.protein.rounded()),
            fat: Int(diet.fat.rounded()),
            dietaryFiber: Int(diet.dietaryFiber.rounded()),
            sugar: Int(diet.sugar.rounded()),
            sodium: Int(diet.sodium.rounded())
        )
    }
    
    return NutritionAnalysisInputForJSON(userProfile: userProfile, meals: mealsForJSON)
}
