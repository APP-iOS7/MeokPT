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
    var activityLevel: ActivityLevel
    var createdDate: Date
    
    init(height: Double, age: Int, weight: Double, gender: Gender, goal: Goal, activityLevel: ActivityLevel) {
        self.height = height
        self.age = age
        self.weight = weight
        self.gender = gender
        self.goal = goal
        self.activityLevel = activityLevel
        self.createdDate = Date()
    }
}
