import ComposableArchitecture
import Foundation
import SwiftData

@Model
class BodyInfo {
    var height: Double
    var age: Int
    var weight: Double
    var gender: String
    var goal: String
    var activityLevel: String = "보통"
    var createdDate: Date = Date()
    
    init(height: Double, age: Int, weight: Double, gender: String, goal: String, activityLevel: String = "보통") {
        self.height = height
        self.age = age
        self.weight = weight
        self.gender = gender
        self.goal = goal
        self.activityLevel = activityLevel
        self.createdDate = Date()
    }
}
