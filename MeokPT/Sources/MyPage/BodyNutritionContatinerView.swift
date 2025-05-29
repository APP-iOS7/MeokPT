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
                VStack {
                    switch selectedTab {
                    case .bodyinInfoInput:
                        BodyInfoInputView(
                            onSaveCompleted: { savedBodyInfoState in
                                if !nutritionStore.isEditable {
                                    print("BodyInfo 저장 완료. DailyNutritionView가 계산 모드이므로 영양 정보 재계산 및 업데이트합니다.")

                                    guard let height = Double(savedBodyInfoState.height),
                                          let age = Int(savedBodyInfoState.age),
                                          let weight = Double(savedBodyInfoState.weight) else {
                                        print("BodyNutritionContainerView (onSaveCompleted): 계산을 위한 신체 정보 값(String)이 유효하지 않습니다.")
                                        return
                                    }

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
                                    
                                    self.nutritionStore.send(.setSaveNutritionRows(newRows, self.modelContext))
                                    print("DailyNutritionFeature의 rows가 새롭게 계산된 값으로 업데이트 및 저장되었습니다.")
                                } else {
                                    print("BodyInfo 저장 완료. DailyNutritionView가 수동 입력 모드이므로 현재는 재계산하지 않습니다.")
                                }
                            }, store: bodyInfoStore
                        )

                    case .dailyNutrition:
                        DailyNutritionView(
                            store: nutritionStore,
                            onSaveTapped: { store, viewContext in
                                let currentNutritionState = ViewStore(store, observe: {$0}).state
                                if !currentNutritionState.isEditable {
                                    guard let height = Double(bodyInfoStore.height),
                                          let age = Int(bodyInfoStore.age),
                                          let weight = Double(bodyInfoStore.weight) else {
                                        print("BodyNutritionContainerView (DailyNutritionView의 onSaveTapped): 계산을 위한 신체 정보 값(String)이 유효하지 않습니다.")
                                        return
                                    }
                                    let nutritionValues = calculateNutrition(
                                        weight: weight,
                                        height: height,
                                        age: age,
                                        gender: bodyInfoStore.selectedGender,
                                        goal: bodyInfoStore.selectedGoal,
                                        activityLevel: bodyInfoStore.selectedActivityLevel
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
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("선택", selection: $selectedTab) {
                            ForEach(SegmentType.allCases) { segment in
                                Text(segment.rawValue).tag(segment)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .fixedSize()
                    }
                }
                .background(Color("AppBackgroundColor"))
                .onAppear {
                    bodyInfoStore.send(.loadSavedData(modelContext))
                }
                .tint(Color("TextButtonColor"))
    }
}
