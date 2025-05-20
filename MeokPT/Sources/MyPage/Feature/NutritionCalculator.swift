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

struct NutrientRatios {
    let carbPercent: Double
    let proteinPercent: Double
    let fatPercent: Double
    let fiberGrams: Double
}


func calculateBMI(weightKg: Double, heightCm: Double) -> Double {
    guard heightCm > 0 else { return 0 }
    let heightM = heightCm / 100
    return weightKg / (heightM * heightM)
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

func adjustCalories(for gender: Gender, goal: Goal, tdee: Double, bmr: Double, bmi: Double) -> Double {
    var bmiCategoryFactor: Double = 1.0

    switch goal {
    case .loseWeight:
        let baseDeficitPercent = gender == .female ? 0.15 : 0.20
        if bmi < 18.5 {
            bmiCategoryFactor = 0.25
        } else if bmi < 25.0 {
            bmiCategoryFactor = 0.8
        } else if bmi < 30.0 {
            bmiCategoryFactor = 1.0
        } else {
            bmiCategoryFactor = 1.1
        }
        let targetDeficit = tdee * baseDeficitPercent * bmiCategoryFactor
        let proposedCalories = tdee - targetDeficit
        
        let minimumCalories = gender == .female ? max(bmr, 1200.0) : max(bmr, 1500.0)
        
        return max(proposedCalories, minimumCalories)
        
    case .gainMuscle:
        let baseSurplusPercent = gender == .female ? 0.10 : 0.12
        if bmi < 18.5 { bmiCategoryFactor = 1.25 }
        else if bmi < 25.0 { bmiCategoryFactor = 1.0 }
        else { bmiCategoryFactor = 0.75 }
        
        let targetSurplus = tdee * baseSurplusPercent * bmiCategoryFactor
        let proposedCalories = tdee + targetSurplus
        return proposedCalories
        
    case .maintainWeight:
        return tdee
    }
}

func getRatios(for gender: Gender, goal: Goal, bmi: Double) -> NutrientRatios {
    var carbP: Double
    var proteinP: Double
    var fatP: Double
    var fiberG: Double = gender == .female ? 25.0 : 30.0

    switch goal {
    case .loseWeight:
        if bmi < 18.5 {
            carbP = 0.45; proteinP = 0.25; fatP = 0.30
        } else if bmi < 25.0 {
            carbP = 0.40; proteinP = 0.30; fatP = 0.30
        } else if bmi < 30.0 {
            carbP = 0.38; proteinP = 0.32; fatP = 0.30
            fiberG += 2.5
        } else {
            carbP = 0.35; proteinP = 0.35; fatP = 0.30
            fiberG += 5.0
        }

    case .gainMuscle:
        if bmi < 18.5 {
            carbP = 0.50; proteinP = 0.25; fatP = 0.25
        } else if bmi < 25.0 {
            carbP = gender == .female ? 0.45 : 0.50
            proteinP = 0.25
            fatP = gender == .female ? 0.30 : 0.25
        } else {
            carbP = gender == .female ? 0.40 : 0.45
            proteinP = 0.30
            fatP = gender == .female ? 0.30 : 0.25
            fiberG += 2.5
        }
        
    case .maintainWeight:
        if bmi < 18.5 {
            carbP = gender == .female ? 0.50 : 0.52
            proteinP = 0.20
            fatP = gender == .female ? 0.30 : 0.28
        } else if bmi < 25.0 {
            carbP = 0.50; proteinP = 0.20; fatP = 0.30
        } else {
            carbP = gender == .female ? 0.45 : 0.48
            proteinP = 0.25
            fatP = gender == .female ? 0.30 : 0.27
            fiberG += 2.5
        }
    }
    
    let sumCheck = carbP + proteinP + fatP
    if abs(sumCheck - 1.0) > 0.001 {
        if sumCheck > 1.0 {
            carbP -= (sumCheck - 1.0)
        } else {
            carbP += (1.0 - sumCheck)
        }
        if carbP < 0 { carbP = 0 }
    }

    return NutrientRatios(carbPercent: carbP, proteinPercent: proteinP, fatPercent: fatP, fiberGrams: fiberG)
}

func calculateNutrition(weight: Double, height: Double, age: Int, gender: Gender, goal: Goal, activityLevel: ActivityLevel) -> NutritionValues {
    let weightKg = weight
    let heightCm = height

    let bmr = calculateBMR(gender: gender, weight: weightKg, height: heightCm, age: age)
    let tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel)
    let bmi = calculateBMI(weightKg: weightKg, heightCm: heightCm)
    
    let adjustedCalories = adjustCalories(for: gender, goal: goal, tdee: tdee, bmr: bmr, bmi: bmi)
    let ratios = getRatios(for: gender, goal: goal, bmi: bmi)
    
    let proteinGrams = (adjustedCalories * ratios.proteinPercent) / 4.0
    let fatGrams = (adjustedCalories * ratios.fatPercent) / 9.0
    let carbsGrams = (adjustedCalories * ratios.carbPercent) / 4.0
    
    let sugarGrams = (adjustedCalories * 0.1) / 4.0
    let sodiumMilligrams = 1500.0
    
    return NutritionValues(
        calories: adjustedCalories,
        carbs: carbsGrams,
        protein: proteinGrams,
        fat: fatGrams,
        fiber: ratios.fiberGrams,
        sugar: sugarGrams,
        sodium: sodiumMilligrams
    )
}

func calculateIdealWeight(heightCm: Double, targetBMI: Double = 22.0) -> Double {
    guard heightCm > 0 else { return 0 }
    let heightM = heightCm / 100
    return targetBMI * heightM * heightM
}

func calculateNutritionForIdealWeight(
    heightCm: Double,
    age: Int,
    gender: Gender,
    activityLevel: ActivityLevel,
    targetBMIForIdealWeight: Double = 22.0
) -> NutritionValues {
    
    let idealWeight = calculateIdealWeight(heightCm: heightCm, targetBMI: targetBMIForIdealWeight)
    
    let bmrForIdealWeight = calculateBMR(gender: gender, weight: idealWeight, height: heightCm, age: age)
    let tdeeForIdealWeight = calculateTDEE(bmr: bmrForIdealWeight, activityLevel: activityLevel)
    let bmiForIdealWeight = calculateBMI(weightKg: idealWeight, heightCm: heightCm)

    let adjustedCalories = adjustCalories(
        for: gender,
        goal: .maintainWeight,
        tdee: tdeeForIdealWeight,
        bmr: bmrForIdealWeight,
        bmi: bmiForIdealWeight
    )

    let ratios = getRatios(
        for: gender,
        goal: .maintainWeight,
        bmi: bmiForIdealWeight
    )

    let proteinGrams = (adjustedCalories * ratios.proteinPercent) / 4.0
    let fatGrams = (adjustedCalories * ratios.fatPercent) / 9.0
    let carbsGrams = (adjustedCalories * ratios.carbPercent) / 4.0
    
    let sugarGrams = (adjustedCalories * 0.1) / 4.0
    let sodiumMilligrams = 1500.0
    
    return NutritionValues(
        calories: adjustedCalories,
        carbs: carbsGrams,
        protein: proteinGrams,
        fat: fatGrams,
        fiber: ratios.fiberGrams,
        sugar: sugarGrams,
        sodium: sodiumMilligrams
    )
}


func generateNutritionItems(from nutrition: NutritionValues) -> [NutritionItem] {
    return [
        NutritionItem(type: .calorie, value: 0, max: Int(nutrition.calories.rounded())),
        NutritionItem(type: .carbohydrate, value: 0, max: Int(nutrition.carbs.rounded())),
        NutritionItem(type: .protein, value: 0, max: Int(nutrition.protein.rounded())),
        NutritionItem(type: .fat, value: 0, max: Int(nutrition.fat.rounded())),
        NutritionItem(type: .dietaryFiber, value: 0, max: Int(nutrition.fiber.rounded())),
        NutritionItem(type: .sugar, value: 0, max: Int(nutrition.sugar.rounded())),
        NutritionItem(type: .sodium, value: 0, max: Int(nutrition.sodium.rounded()))
    ]
}
