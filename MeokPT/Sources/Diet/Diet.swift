import Foundation
import ComposableArchitecture

@ObservableState
struct Diet: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    // MARK: - 아침 / 점심 / 저녁 / 간식 중 택 1
    var mealType: String
    var title: String
    var kcal: Double
    var carbohydrate: Double
    var protein: Double
    var fat: Double
    // MARK: - 식이섬유, 당분, 나트륨
    var dietaryFiber: Double
    var sugar: Double
    var sodium: Double
    var isFavorite: Bool
}
