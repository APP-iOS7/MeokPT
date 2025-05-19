enum Gender: String, CaseIterable, Identifiable, Equatable, Codable, Hashable {
    case female = "여성"
    case male = "남성"
    
    var id: String { rawValue }
    
    var description: String { rawValue }
}
