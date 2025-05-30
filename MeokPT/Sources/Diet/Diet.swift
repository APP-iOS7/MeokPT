import Foundation
import ComposableArchitecture

struct Food: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    let name: String
    var amount: Double
    var kcal: Double
    var carbohydrate: Double
    var protein: Double
    var fat: Double
    var dietaryFiber: Double
    var sodium: Double
    var sugar: Double
}

@ObservableState
struct Diet: Identifiable, Equatable, Hashable {
    let id: UUID = UUID()
    var title: String
    var isFavorite: Bool
    var foods: [Food]

    var kcal: Double {
        foods.reduce(0) { $0 + $1.kcal }
    }
    var carbohydrate: Double {
        foods.reduce(0) { $0 + $1.carbohydrate }
    }
    var protein: Double {
        foods.reduce(0) { $0 + $1.protein }
    }
    var fat: Double {
        foods.reduce(0) { $0 + $1.fat }
    }
    var dietaryFiber: Double {
        foods.reduce(0) { $0 + $1.dietaryFiber }
    }
    var sodium: Double {
        foods.reduce(0) { $0 + $1.sodium }
    }
    var sugar: Double {
        foods.reduce(0) { $0 + $1.sugar }
    }
}
