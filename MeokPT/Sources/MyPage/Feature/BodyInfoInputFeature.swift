import ComposableArchitecture
import SwiftData

@Reducer
struct BodyInfoInputFeature: Reducer {
    struct State: Equatable {
        var height : String = ""
        var age : String = ""
        var weight: String = ""
        var selectedGender: String = "여성"
        var selectedGoal: String = "체중감량"
        var error: String?
    }

    enum Action: Equatable {
        case heightChanged(String)
        case ageChanged(String)
        case weightChanged(String)
        case genderChanged(String)
        case goalChanged(String)
        case saveButtonTapped(ModelContext)
        case loadSavedData(ModelContext)
    }
        
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .heightChanged(text):
                state.height = text
                return .none
            case let .ageChanged(text):
                state.age = text
                return .none
            case let .weightChanged(text):
                state.weight = text
                return .none
            case let .genderChanged(text):
                state.selectedGender = text
                return .none
            case let .goalChanged(text):
                state.selectedGoal = text
                return .none
            case let .loadSavedData(context):
                print("\n데이터 로드 시작")
                if let existing = try? context.fetch(FetchDescriptor<BodyInfo>()).first {
                    state.height = String(existing.height)
                    state.age = String(existing.age)
                    state.weight = String(existing.weight)
                    state.selectedGender = existing.gender
                    state.selectedGoal = existing.goal
                    print("데이터 로드 성공")
                } else {
                    print("저장된 데이터가 없습니다.")
                }
                return .none
            case let .saveButtonTapped(context):
                print("데이터 저장 시작")
                do  {
                    if let existing = try context.fetch(FetchDescriptor<BodyInfo>()).first {
                        print("기존 데이터 업데이트")
                        existing.height = Double(state.height) ?? 0
                        existing.age = Int(state.age) ?? 0
                        existing.weight = Double(state.weight) ?? 0
                        existing.gender = state.selectedGender
                        existing.goal = state.selectedGoal
                    } else {
                        let newInfo = BodyInfo(
                            height: Double(state.height) ?? 0,
                            age: Int(state.age) ?? 0,
                            weight: Double(state.weight) ?? 0,
                            gender: state.selectedGender,
                            goal: state.selectedGoal
                        )
                        context.insert(newInfo)
                        print("새로운 데이터 생성")
                    }
                    try context.save()
                    print("데이터 저장 성공")
                } catch {
                    print("저장 실패: \(error)")
                }
                return .none
            }
        }
    }
}

