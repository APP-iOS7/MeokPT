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

// 액터 간 전송용 Sendable 데이터 구조체
struct BodyInfoData: Sendable, Equatable {
    let height: Int
    let age: Int
    let weight: Int
    let genderRawValue: String
    let goalRawValue: String
    let activityLevelRawValue: Double
    
    // BodyInfo에서 BodyInfoData로 변환
    init(from bodyInfo: BodyInfo) {
        self.height = bodyInfo.height
        self.age = bodyInfo.age
        self.weight = bodyInfo.weight
        self.genderRawValue = bodyInfo.genderRawValue
        self.goalRawValue = bodyInfo.goalRawValue
        self.activityLevelRawValue = bodyInfo.activityLevelRawValue
    }
    
    // 편의 computed properties
    var gender: Gender? {
        Gender(rawValue: genderRawValue)
    }
    
    var goal: Goal? {
        Goal(rawValue: goalRawValue)
    }
    
    var activityLevel: ActivityLevel? {
        ActivityLevel(rawValue: activityLevelRawValue)
    }
}
