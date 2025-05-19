import Foundation

struct NutritionValues {
    let calories: Double
    let carbs: Double
    let protein: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let sodium: Double
}

struct NutrientRatios{
    let carbPercent: Double
    let proteinPerKg: Double
    let fatPercent: Double
    let fiber: Double
}

func calculateBMR(gender: Gender, weight: Double, height: Double, age: Int) -> Double {
    if gender == Gender.male {
        return 10 * weight + 6.25 * height - 5 * Double(age) + 5
    } else {
        return 10 * weight + 6.25 * height - 5 * Double(age) - 161
    }
}

func calculateTDEE(bmr: Double, activityLevel: ActivityLevel) -> Double {
    return bmr * activityLevel.rawValue
}

func adjustCalories(for gender: Gender, goal: Goal, bmr: Double) -> Double {
    switch goal {
    case .loseWeight:
        return gender == Gender.female ? bmr - 350 : bmr - 550
    case .gainMuscle:
        return gender == Gender.female ? bmr + 300 : bmr + 400
    default:
        return bmr
    }
}

func getRatios(for gender: Gender, goal: Goal) -> NutrientRatios {
    switch goal {
    case .loseWeight:
        return gender == Gender.female
        ? NutrientRatios(carbPercent: 0.45, proteinPerKg: 1.9, fatPercent: 0.275, fiber: 22.5)
        : NutrientRatios(carbPercent: 0.525, proteinPerKg: 2.1, fatPercent: 0.225, fiber: 27.5)
    case .gainMuscle:
        return gender == Gender.female
        ? NutrientRatios(carbPercent: 0.475, proteinPerKg: 1.9, fatPercent: 0.275, fiber: 22.5)
        : NutrientRatios(carbPercent: 0.575, proteinPerKg: 2.35, fatPercent: 0.225, fiber: 27.5)
    default:
        return gender == Gender.female
        ? NutrientRatios(carbPercent: 0.525, proteinPerKg: 1.4, fatPercent: 0.275, fiber: 22.5)
        : NutrientRatios(carbPercent: 0.575, proteinPerKg: 1.6, fatPercent: 0.225, fiber: 27.5)
    }
}

func calculateNutrition(weight: Double, height: Double, age: Int, gender: Gender, goal: Goal, activityLevel: ActivityLevel) -> NutritionValues {
    let bmr = calculateBMR(gender: gender, weight: weight, height: height, age: age)
    let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
    let adjustedCalories = adjustCalories(for: gender, goal: goal, bmr: tdee)
    let ratios = getRatios(for: gender, goal: goal)
    
    let protein = weight * ratios.proteinPerKg
    let proteininKcal = weight * 4
    let fatKcal = adjustedCalories * ratios.fatPercent
    let fat = fatKcal / 9
    let carbKcal = adjustedCalories * ratios.carbPercent
    let carbs = carbKcal / 4
    let sugar = adjustedCalories * 0.1 / 4
    let sodium = 1500.0
    
    return NutritionValues(
        calories: adjustedCalories,
        carbs: carbs,
        protein: protein,
        fat: fat,
        fiber: ratios.fiber,
        sugar: sugar,
        sodium: sodium
    )
}

func generateNutritionItems(from nutrition: NutritionValues) -> [NutritionItem] {
    return [
        NutritionItem(type: .calorie, value: 0, max: Int(nutrition.calories.rounded())),
        NutritionItem(type: .carbohydrate, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .protein, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .fat, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .dietaryFiber, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .sugar, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .sodium, value: 0, max: Int(nutrition.carbs.rounded())),
    ]
}

