struct NutritionRowData: Identifiable, Equatable {
    let type: NutritionType
    var value: String
    
    var id: String { type.id }
    var name: String { type.rawValue }
    var unit: String { type.unit }
}
