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
        WithViewStore(self.bodyInfoStore, observe: { $0 }) { bodyViewStore in
            WithViewStore(self.nutritionStore, observe: { $0 }) { nutritionViewStoreObserved in
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
                        BodyInfoInputView(store: bodyInfoStore)
                            .onDisappear {
                                if !nutritionViewStoreObserved.isEditable {
                                    print("BodyInfoInputView disappeared. Checking if nutrition needs recalculation.")
                                }
                            }
                    case .dailyNutrition:
                        DailyNutritionView(
                            store: nutritionStore,
                            onSaveTapped: { store, viewContext in
                                let currentNutritionState = ViewStore(store, observe: {$0}).state

                                if !currentNutritionState.isEditable {
                                    print("저장 요청: isEditable is false. BodyInfo 기반으로 계산합니다.")
                                    guard let height = Double(bodyViewStore.height),
                                          let age = Int(bodyViewStore.age),
                                          let weight = Double(bodyViewStore.weight) else {
                                        print("BodyNutritionContainerView: 신체 정보가 유효하지 않아 계산할 수 없습니다.")
                                        return
                                    }

                                    let nutritionValues = calculateNutrition(
                                        weight: weight,
                                        height: height,
                                        age: age,
                                        gender: bodyViewStore.selectedGender,
                                        goal: bodyViewStore.selectedGoal,
                                        activityLevel: bodyViewStore.selectedActivityLevel
                                    )

                                    let calculatedNutritionItems = generateNutritionItems(from: nutritionValues)
                                    let newRows = calculatedNutritionItems.map { item in
                                        NutritionRowData(type: item.type, value: String(item.max))
                                    }

                                    store.send(.setSaveNutritionRows(newRows, self.modelContext)) // self.modelContext 사용
                                } else {
                                    print("저장 요청: isEditable is true. 수동 입력값을 저장합니다.")
                                    store.send(.saveCurrentManualEntries(self.modelContext)) // self.modelContext 사용
                                }
                            }
                        )
                    }
                    Spacer()
                }
                .background(Color("AppBackgroundColor"))
                .onAppear {
                    bodyInfoStore.send(.loadSavedData(modelContext))
                }
            }
        }
    }
}
