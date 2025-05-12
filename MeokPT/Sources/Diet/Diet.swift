import Foundation
import ComposableArchitecture

@ObservableState
struct Diet: Identifiable, Equatable {
    let id: UUID = UUID()
    var title: String
    var kcal: Double
    var carbohydrate: Double
    var protein: Double
    var fat: Double
    var isFavorite: Bool
}
