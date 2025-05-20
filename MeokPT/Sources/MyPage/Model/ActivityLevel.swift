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
            return "좌식 생활 위주,\n운동 거의 안 함"
        case .low:
            return "가벼운 운동 (주 1-3회),\n또는 규칙적인 산책"
        case .medium:
            return "보통의 활동 (주 3-5회 운동),\n또는 활동적인 취미"
        case .activity:
            return "적극적인 활동 (주 6-7회 운동),\n또는 육체 노동 포함"
        case .veryActivity:
            return "매우 높은 활동량,\n매일 운동 또는 힘든 육체노동"
        }
    }
}
