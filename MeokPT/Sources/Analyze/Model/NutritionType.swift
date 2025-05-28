enum NutritionType: String, CaseIterable, Identifiable, Equatable {
    case calorie = "열량"
    case carbohydrate = "탄수화물"
    case protein = "단백질"
    case fat = "지방"
    case dietaryFiber = "식이섬유"
    case sugar = "당류"
    case sodium = "나트륨"
    
    var id: String { self.rawValue }
    var unit: String {
        switch self {
        case .calorie: return "kcal"
        case .sodium: return "mg"
        default: return "g"
        }
    }
    
    var jsonKey: String {
        switch self {
        case .calorie: return "calories"
        case .carbohydrate: return "carbohydrates"
        case .protein: return "protein"
        case .fat: return "fat"
        case .dietaryFiber: return "dietaryFiber"
        case .sugar: return "sugar"
        case .sodium: return "sodium"
        }
    }
}
