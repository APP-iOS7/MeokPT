import SwiftUI
import ComposableArchitecture

struct BodyNutritionContainerView: View {
    let initialTab: SegmentType
    let bodyInfoStore: StoreOf<BodyInfoInputFeature>
    let nutritionStore: StoreOf<DailyNutritionFeature>
    
    @State private var selectedTab: SegmentType
    
    init(initialTab: SegmentType, bodyInfoStore: StoreOf<BodyInfoInputFeature>, nutritionStore: StoreOf<DailyNutritionFeature>) {
        self.initialTab = initialTab
        self.bodyInfoStore = bodyInfoStore
        self.nutritionStore = nutritionStore
        _selectedTab = State(initialValue: initialTab)
    }
    
    var body: some View {
        VStack {
            Picker("선택", selection: $selectedTab) {
                ForEach(SegmentType.allCases) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedTab {
            case .bodyinInfoInput:
                BodyInfoInputView(store: bodyInfoStore)
            case .dailyNutrition:
                DailyNutritionView(store: nutritionStore)
            }
        }
        .navigationTitle("건강 목표 설정")
        .background(Color("AppbackgroundColor"))
    }
}
