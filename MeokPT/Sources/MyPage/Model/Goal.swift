enum Goal: String, CaseIterable , Identifiable, Equatable, Codable, Hashable {
    case loseWeight = "체중감량"
    case gainMuscle = "근육량 증가"
    case other
    
    var id: String { rawValue }
}
