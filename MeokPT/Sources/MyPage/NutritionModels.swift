//
//  NutritionModels.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import Foundation

struct ParsedNutritionData: Codable {
    let meals: [ParsedMeal]?
    let userProfile: UserAnalyzeProfile?
    
    private enum CodingKeys: String, CodingKey {
        case meals, userProfile
    }
    
    // 실제 데이터를 가져오는 computed property
    var actualMeals: [ParsedMeal] {
        return meals ?? []
    }
    
    var actualRecommendedIntake: [ParsedNutritionItem] {
        guard let profile = userProfile,
              let intake = profile.dailyRecommendedIntake else { return [] }
        
        return [
//            ParsedNutritionItem(nutrientName: "열량", recommendedIntake: intake.calories, unit: "kcal"),
            ParsedNutritionItem(nutrientName: "탄수화물", recommendedIntake: intake.carbohydrates, unit: "g"),
            ParsedNutritionItem(nutrientName: "단백질", recommendedIntake: intake.protein, unit: "g"),
            ParsedNutritionItem(nutrientName: "지방", recommendedIntake: intake.fat, unit: "g"),
            ParsedNutritionItem(nutrientName: "식이섬유", recommendedIntake: intake.dietaryFiber, unit: "g"),
            ParsedNutritionItem(nutrientName: "당류", recommendedIntake: intake.sugar, unit: "g"),
            ParsedNutritionItem(nutrientName: "나트륨", recommendedIntake: intake.sodium, unit: "mg")
        ]
    }
}

struct UserAnalyzeProfile: Codable {
    let dailyRecommendedIntake: DailyRecommendedIntake?
}

struct DailyRecommendedIntake: Codable {
    let calories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let dietaryFiber: Double
    let sugar: Double
    let sodium: Double
}

struct ParsedMeal: Codable, Identifiable {
    let id = UUID()
    let mealType: String
    let dietTitle: String?
    let calories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let dietaryFiber: Double
    let sugar: Double
    let sodium: Double
    
    private enum CodingKeys: String, CodingKey {
        case mealType, dietTitle, calories, carbohydrates, protein, fat, dietaryFiber, sugar, sodium
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mealType = try container.decode(String.self, forKey: .mealType)
        dietTitle = try container.decodeIfPresent(String.self, forKey: .dietTitle)
        calories = try container.decode(Double.self, forKey: .calories)
        carbohydrates = try container.decode(Double.self, forKey: .carbohydrates)
        protein = try container.decode(Double.self, forKey: .protein)
        fat = try container.decode(Double.self, forKey: .fat)
        dietaryFiber = try container.decode(Double.self, forKey: .dietaryFiber)
        sugar = try container.decode(Double.self, forKey: .sugar)
        sodium = try container.decode(Double.self, forKey: .sodium)
    }
    
    // dietTitle이 있으면 사용하고, 없으면 기본값 반환
    var displayTitle: String {
        return dietTitle ?? "식사 정보"
    }
}

struct ParsedNutritionItem: Identifiable {
    let id = UUID()
    let nutrientName: String
    let recommendedIntake: Double
    let unit: String
    
    init(nutrientName: String, recommendedIntake: Double, unit: String) {
        self.nutrientName = nutrientName
        self.recommendedIntake = recommendedIntake
        self.unit = unit
    }
}

extension String {
    // 식사 타입 표시명 변환
    var mealTypeDisplayName: String {
        switch self {
        case "breakfast":
            return "아침"
        case "lunch":
            return "점심"
        case "dinner":
            return "저녁"
        case "snack":
            return "간식"
        default:
            return self
        }
    }
    
    // 식사 타입 아이콘
    var mealTypeIcon: String {
        switch self {
        case "breakfast":
            return "sun.rise.fill"
        case "lunch":
            return "sun.max.fill"
        case "dinner":
            return "moon.fill"
        case "snack":
            return "gift.fill"
        default:
            return "fork.knife"
        }
    }
}
