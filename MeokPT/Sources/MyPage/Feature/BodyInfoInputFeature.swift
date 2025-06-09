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
        
        case saveButtonTapped
        case loadSavedData
        case hideToast
        
        case _handleLoadedBodyInfoData(BodyInfoData?)
        case _handleSaveSuccess
        case _handleSaveError(String)
    }
    
    @Dependency(\.modelContainer) var modelContainer
    
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
                
            case .loadSavedData:
                print("\n데이터 로드 요청 (Reducer)")
                
                return .run { [modelContainer] send in
                    let loadedData: BodyInfoData? = await MainActor.run {
                        let context = modelContainer.mainContext
                        print("데이터 로드 시작 (Effect on MainActor)")
                        if let model = try? context.fetch(FetchDescriptor<BodyInfo>()).first {
                            print("BodyInfo 모델 로드 성공 (Effect)")
                            return BodyInfoData(from: model) // 변환해서 반환
                        } else {
                            print("저장된 BodyInfo 모델 없음 (Effect)")
                            return nil
                        }
                    }
                    await send(._handleLoadedBodyInfoData(loadedData))
                }
                
            case let ._handleLoadedBodyInfoData(data):
                print("로드된 데이터 처리 (Reducer)")
                if let loaded = data {
                    state.height = String(loaded.height)
                    state.age = String(loaded.age)
                    state.weight = String(loaded.weight)
                    
                    if let loadedGender = Gender(rawValue: loaded.genderRawValue) {
                        state.selectedGender = loadedGender
                    } else {
                        state.selectedGender = .female
                        print("경고: 저장된 genderRawValue로부터 Gender Enum 로드 실패: \(loaded.genderRawValue)")
                    }
                    
                    if let loadedGoal = Goal(rawValue: loaded.goalRawValue) {
                        state.selectedGoal = loadedGoal
                    } else {
                        state.selectedGoal = .maintainWeight
                        print("경고: 저장된 goalRawValue로부터 Goal Enum 로드 실패: \(loaded.goalRawValue)")
                    }
                    
                    if let loadedActivityLevel = ActivityLevel(rawValue: loaded.activityLevelRawValue) {
                        state.selectedActivityLevel = loadedActivityLevel
                    } else {
                        state.selectedActivityLevel = .veryLow
                        print("경고: 저장된 activityLevelRawValue로부터 ActivityLevel Enum 로드 실패: \(loaded.activityLevelRawValue)")
                    }
                    print("데이터 로드 및 상태 업데이트 성공 (Reducer)")
                } else {
                    print("저장된 데이터 없음 (Reducer)")
                }
                return .none
            case .saveButtonTapped:
                print("저장 버튼 탭 (Reducer)")
                let heightS = state.height
                let ageS = state.age
                let weightS = state.weight
                let gender = state.selectedGender
                let goal = state.selectedGoal
                let activityLevel = state.selectedActivityLevel
                
                return .run { [modelContainer] send in
                    print("데이터 저장 시작 (Effect)")
                    do {
                        try await MainActor.run {
                            let context = modelContainer.mainContext
                            let heightValue = Int(heightS) ?? 0
                            let ageValue = Int(ageS) ?? 0
                            let weightValue = Int(weightS) ?? 0
                            let genderRawValue = gender.rawValue
                            let goalRawValue = goal.rawValue
                            let activityLevelRawValue = activityLevel.rawValue

                            if let existing = try context.fetch(FetchDescriptor<BodyInfo>()).first {
                                print("기존 데이터 업데이트 (Effect on MainActor)")
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
                                print("새로운 데이터 생성 (Effect on MainActor)")
                            }
                            try context.save()
                        }
                        print("데이터 저장 성공 (Effect)")
                        await send(._handleSaveSuccess)
                    } catch {
                        print("저장 실패 (Effect): \(error.localizedDescription)")
                        await send(._handleSaveError(error.localizedDescription))
                    }
                }
                
            case ._handleSaveSuccess:
               print("저장 성공 처리 (Reducer)")
               state.showAlertToast = true
               state.error = nil
               return .run { send in
                   try await Task.sleep(for: .seconds(4))
                   await send(.hideToast)
               }
               
           case let ._handleSaveError(errorMessage):
               print("저장 실패 처리 (Reducer): \(errorMessage)")
               state.error = errorMessage
               return .none

            case .hideToast:
                state.showAlertToast = false
                return .none
            }
        }
    }
}

