enum ActivityLevel: Double, CaseIterable, Identifiable, Equatable, Codable, Hashable {
    case veryLow = 1.2
    case low = 1.375
    case medium = 1.55
    case activity = 1.725
    case veryActivity = 1.9

    var id: Double { rawValue }

    var title: String {
        switch self {
        case .veryLow: return "매우 적음"
        case .low: return "적음"
        case .medium: return "보통"
        case .activity: return "많음"
        case .veryActivity: return "매우 많음"
        }
    }

    var description: String {
        switch self {
        case .veryLow:
            return "운동을 거의 안 함\n좌식 생활 위주"
        case .low:
            return "가벼운 활동\n주 1-2회 운동"
        case .medium:
            return "보통의 활동\n주 3-5회 운동"
        case .activity:
            return "적극적인 활동\n주 6-7회 운동"
        case .veryActivity:
            return "운동 중심의 일상\n또는 힘든 육체 노동"
        }
    }
}
