import ComposableArchitecture
import Foundation
import SwiftData

@Model
class BodyInfo {
    var height: Double
    var age: Int
    var weight: Double
    var gender: Gender
    var goal: Goal
    var createdDate: Date
    
    init(height: Double, age: Int, weight: Double, gender: String, goal: String) {
        self.height = height
        self.age = age
        self.weight = weight
        self.gender = gender
        self.goal = goal
        self.activityLevel = activityLevel
        self.createdDate = Date()
    }
}
