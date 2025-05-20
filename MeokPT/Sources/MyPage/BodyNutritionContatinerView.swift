import SwiftUI
import ComposableArchitecture
import SwiftData

struct BodyNutritionContainerView: View {
    let initialTab: SegmentType
    let bodyInfoStore: StoreOf<BodyInfoInputFeature>
    let nutritionStore: StoreOf<DailyNutritionFeature>

    @State private var selectedTab: SegmentType
    @Environment(\.modelContext) private var modelContext

    init(initialTab: SegmentType, bodyInfoStore: StoreOf<BodyInfoInputFeature>, nutritionStore: StoreOf<DailyNutritionFeature>) {
        self.initialTab = initialTab
        self.bodyInfoStore = bodyInfoStore
        self.nutritionStore = nutritionStore
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        // bodyInfoStore의 상태를 관찰하기 위해 bodyViewStore_ObservedState 사용 (내부 클로저와의 이름 충돌 방지)
        WithViewStore(self.bodyInfoStore, observe: { $0 }) { bodyViewStore_ObservedState in
            // nutritionStore의 상태를 관찰하기 위해 nutritionViewStore_ObservedState 사용
            WithViewStore(self.nutritionStore, observe: { $0 }) { nutritionViewStore_ObservedState in
                VStack {
                    Picker("선택", selection: $selectedTab) {
                        ForEach(SegmentType.allCases) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .frame(width: 194, height: 25)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()

                    switch selectedTab {
                    case .bodyinInfoInput:
                        BodyInfoInputView(
                            store: bodyInfoStore,
                            onSaveCompleted: { savedBodyInfoState in // << NEW: onSaveCompleted 클로저 구현
                                // BodyInfoInputView에서 "완료"가 눌리고, 해당 뷰의 상태가 전달됨
                                
                                // DailyNutritionView가 "수치 직접 입력" 모드가 아닌지 확인
                                if !nutritionViewStore_ObservedState.isEditable {
                                    print("BodyInfo 저장 완료. DailyNutritionView가 계산 모드이므로 영양 정보 재계산 및 업데이트합니다.")

                                    // 전달받은 savedBodyInfoState (String 값 포함)를 계산에 필요한 타입으로 변환
                                    guard let height = Double(savedBodyInfoState.height),
                                          let age = Int(savedBodyInfoState.age),
                                          let weight = Double(savedBodyInfoState.weight) else {
                                        print("BodyNutritionContainerView (onSaveCompleted): 계산을 위한 신체 정보 값(String)이 유효하지 않습니다.")
                                        return
                                    }

                                    // 영양 정보 계산
                                    let nutritionValues = calculateNutrition(
                                        weight: weight,
                                        height: height,
                                        age: age,
                                        gender: savedBodyInfoState.selectedGender,
                                        goal: savedBodyInfoState.selectedGoal,
                                        activityLevel: savedBodyInfoState.selectedActivityLevel
                                    )
                                    let calculatedItems = generateNutritionItems(from: nutritionValues)
                                    let newRows = calculatedItems.map { item in
                                        NutritionRowData(type: item.type, value: String(item.max))
                                    }
                                    
                                    // DailyNutritionFeature의 상태를 업데이트하고 SwiftData에 저장
                                    // 이 액션은 DailyNutritionFeature.State.rows를 newRows로 변경하고,
                                    // DailyNutritionView가 이를 감지하여 UI를 업데이트합니다.
                                    // 또한 performSave를 호출하여 변경된 내용을 SwiftData에도 저장합니다.
                                    self.nutritionStore.send(.setSaveNutritionRows(newRows, self.modelContext))
                                    print("DailyNutritionFeature의 rows가 새롭게 계산된 값으로 업데이트 및 저장되었습니다.")
                                } else {
                                    print("BodyInfo 저장 완료. DailyNutritionView가 수동 입력 모드이므로 현재는 재계산하지 않습니다.")
                                }
                            }
                        )
                        // .onDisappear 로직은 필요에 따라 유지 (탭 변경 시의 다른 동작을 위함이라면)

                    case .dailyNutrition:
                        DailyNutritionView(
                            store: nutritionStore,
                            onSaveTapped: { store, viewContext in
                                // 이 클로저는 DailyNutritionView 내부의 "완료" 버튼에 대한 로직
                                let currentNutritionState = ViewStore(store, observe: {$0}).state
                                if !currentNutritionState.isEditable {
                                    // 현재 bodyInfoStore의 상태(bodyViewStore_ObservedState)를 기반으로 계산
                                    guard let height = Double(bodyViewStore_ObservedState.height), // bodyViewStore_ObservedState 사용
                                          let age = Int(bodyViewStore_ObservedState.age),
                                          let weight = Double(bodyViewStore_ObservedState.weight) else {
                                        print("BodyNutritionContainerView (DailyNutritionView의 onSaveTapped): 계산을 위한 신체 정보 값(String)이 유효하지 않습니다.")
                                        return
                                    }
                                    let nutritionValues = calculateNutrition(
                                        weight: weight,
                                        height: height,
                                        age: age,
                                        gender: bodyViewStore_ObservedState.selectedGender,
                                        goal: bodyViewStore_ObservedState.selectedGoal,
                                        activityLevel: bodyViewStore_ObservedState.selectedActivityLevel
                                    )
                                    let newRows = generateNutritionItems(from: nutritionValues).map {
                                        NutritionRowData(type: $0.type, value: String($0.max))
                                    }
                                    store.send(.setSaveNutritionRows(newRows, self.modelContext))
                                } else {
                                    store.send(.saveCurrentManualEntries(self.modelContext))
                                }
                            }
                        )
                    }
                    Spacer()
                }
                .background(Color("AppBackgroundColor"))
                .onAppear {
                    bodyInfoStore.send(.loadSavedData(modelContext))
                    // DailyNutritionView의 초기 데이터 로드는 해당 뷰의 .onAppear에서 처리
                }
            }
        }
    }
}
