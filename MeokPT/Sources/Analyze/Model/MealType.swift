enum MealType: String, Codable, CaseIterable {
    case none = "해당없음"
    case breakfast = "아침"
    case lunch = "점심"
    case dinner = "저녁"
    case snack = "간식"
    
    var displayName: String {
        return self.rawValue
    }
}
