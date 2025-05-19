enum ActivityLevel: Double, CaseIterable, Identifiable, Equatable {
    case veryLow = 1.2
    case low = 1.375
    case medium = 1.55
    case activity = 1.725
    case veryActivity = 1.9
    
    var id: Double { rawValue }
}

