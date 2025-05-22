enum SegmentType: String, CaseIterable, Identifiable {
    case bodyinInfoInput = "내 정보"
    case dailyNutrition = "하루 섭취량"
    
    var id: String { rawValue }
}
