import ComposableArchitecture
import SwiftData

@Reducer
struct BodyInfoInputFeature {
    @ObservableState
    struct State: Equatable {
        var height : String = ""
        var age : String = ""
        var weight: String = ""
        var selectedGender: Gender = .female
        var selectedGoal: Goal = .loseWeight
        var selectedActivityLevel: ActivityLevel = .veryLow
        var error: String?
        var showAlertToast = false
    }
    
    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case heightChanged(String)
        case ageChanged(String)
        case weightChanged(String)
        case genderChanged(Gender)
        case goalChanged(Goal)
        case activityLevelChanged(ActivityLevel)
        case saveButtonTapped(ModelContext)
        case loadSavedData(ModelContext)
        case hideToast
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case let .heightChanged(text):
                state.height = text
                return .none
            case let .ageChanged(text):
                state.age = text
                return .none
            case let .weightChanged(text):
                state.weight = text
                return .none
            case let .genderChanged(selectedCase):
                state.selectedGender = selectedCase
                return .none
            case let .goalChanged(selectedCase):
                state.selectedGoal = selectedCase
                return .none
            case let .activityLevelChanged(selectedCase):
                state.selectedActivityLevel = selectedCase
                return .none
                
            case let .loadSavedData(context):
               print("\n데이터 로드 시작")
               if let existing = try? context.fetch(FetchDescriptor<BodyInfo>()).first {
                   state.height = String(existing.height)
                   state.age = String(existing.age)
                   state.weight = String(existing.weight)
                   
                   if let loadedGender = Gender(rawValue: existing.genderRawValue) {
                       state.selectedGender = loadedGender
                   } else {
                       state.selectedGender = .female // 기본값 또는 오류 처리
                       print("경고: 저장된 genderRawValue로부터 Gender Enum 로드 실패: \(existing.genderRawValue)")
                   }
                   
                   if let loadedGoal = Goal(rawValue: existing.goalRawValue) {
                       state.selectedGoal = loadedGoal
                   } else {
                       state.selectedGoal = .maintainWeight // 기본값 또는 오류 처리
                       print("경고: 저장된 goalRawValue로부터 Goal Enum 로드 실패: \(existing.goalRawValue)")
                   }
                   
                   if let loadedActivityLevel = ActivityLevel(rawValue: existing.activityLevelRawValue) {
                       state.selectedActivityLevel = loadedActivityLevel
                   } else {
                       state.selectedActivityLevel = .veryLow
                       print("경고: 저장된 activityLevelRawValue로부터 ActivityLevel Enum 로드 실패: \(existing.activityLevelRawValue)")
                   }
                   
                   print("데이터 로드 성공")
               } else {
                   print("저장된 데이터가 없습니다.")
               }
               return .none
            case let .saveButtonTapped(context):
                 print("데이터 저장 시작")
                 do {
                     let heightValue = Int(state.height) ?? 0
                     let ageValue = Int(state.age) ?? 0
                     let weightValue = Int(state.weight) ?? 0
                     let genderRawValue = state.selectedGender.rawValue
                     let goalRawValue = state.selectedGoal.rawValue
                     let activityLevelRawValue = state.selectedActivityLevel.rawValue

                     if let existing = try context.fetch(FetchDescriptor<BodyInfo>()).first {
                         print("기존 데이터 업데이트")
                         existing.height = heightValue
                         existing.age = ageValue
                         existing.weight = weightValue
                         existing.genderRawValue = genderRawValue
                         existing.goalRawValue = goalRawValue
                         existing.activityLevelRawValue = activityLevelRawValue
                     } else {
                         let newInfo = BodyInfo(
                             height: heightValue,
                             age: ageValue,
                             weight: weightValue,
                             genderRawValue: genderRawValue,
                             goalRawValue: goalRawValue,
                             activityLevelRawValue: activityLevelRawValue
                         )
                         context.insert(newInfo)
                         print("새로운 데이터 생성")
                     }
                     try context.save()
                     print("데이터 저장 성공")
                     
                     state.showAlertToast = true
                     return .run { send in
                         try await Task.sleep(for: .seconds(4))
                         await send(.hideToast)
                     }
                 } catch {
                     print("저장 실패: \(error)")
                     return .none
                 }
            case .hideToast:
                state.showAlertToast = false
                return .none
            }
        }
    }
}

