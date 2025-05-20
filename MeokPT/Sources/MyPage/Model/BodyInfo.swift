import Foundation
import SwiftData

@Model
final class BodyInfo {
    var height: Int
    var age: Int
    var weight: Int
    var genderRawValue: String
    var goalRawValue: String
    var activityLevelRawValue: Double
    
    init(height: Int,
         age: Int,
         weight: Int,
         genderRawValue: String,
         goalRawValue: String,
         activityLevelRawValue: Double) {
        self.height = height
        self.age = age
        self.weight = weight
        self.genderRawValue = genderRawValue
        self.goalRawValue = goalRawValue
        self.activityLevelRawValue = activityLevelRawValue
    }

    var gender: Gender? {
        get { Gender(rawValue: self.genderRawValue) }
        set { self.genderRawValue = newValue?.rawValue ?? "" }
    }

    var goal: Goal? {
        get { Goal(rawValue: self.goalRawValue) }
        set { self.goalRawValue = newValue?.rawValue ?? "" }
    }

    var activityLevel: ActivityLevel? {
        get { ActivityLevel(rawValue: self.activityLevelRawValue) }
        set { self.activityLevelRawValue = newValue?.rawValue ?? ActivityLevel.veryLow.rawValue }
    }
}
