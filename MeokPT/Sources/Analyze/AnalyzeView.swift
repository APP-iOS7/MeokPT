import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    let store: StoreOf<AnalyzeFeature>
    
    // 테스트용 데이터
    var nutritionInfo: [(key: String, value: Int)] = [
        ("열량", 2100),
        ("탄수화물", 20),
        ("단백질", 10),
        ("지방", 5),
        ("식이섬유", 3),
        ("당류", 8),
        ("나트륨", 200)
    ]
    
    let units: [String] = ["kcal", "g", "g", "g", "g", "g", "mg"]

    let maxNutritionInfo: [Int] = [2000, 100, 56, 35, 28, 20, 2000]
    
        
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - 신체 정보가 없는 경우
//                Text("신체 정보가 없습니다")
//                    .font(.headline)
//                    .foregroundStyle(Color.secondary)
//                
                // MARK: - 신체 정보가 있는 경우
                VStack {
                    ForEach(Array(nutritionInfo.enumerated()), id: \.0) { index, item in
                        let unit = units[index]
                        let maxNutrition = maxNutritionInfo[index]
                        
                        VStack {
                            HStack {
                                Text("\(item.key)")
                                Spacer()
                                Text("\(item.value)\(unit) / \(maxNutrition)\(unit)")
                            }
                            ConditionalProgressView(current: Double(item.value), max: Double(maxNutrition))
                        }
                        .padding(10)
                    }
                }
                .padding(24)
                
                Spacer()
                
                // MARK: - 식단이 없는 경우
                Text("추가한 식단이 없습니다")
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .navigationTitle("분석")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
        }
    }
}

struct ConditionalProgressView: View {
    var current: Double
    var max: Double
    
    var progressColor: Color {
        current > max ? .red : Color("Green")
    }
    
    var progressValue: Double {
        min(current, max)
    }
    
    var body: some View {
        ProgressView(value: progressValue, total: max)
            .tint(progressColor)
    }
}

#Preview {
    AnalyzeView(
        store: Store(initialState: AnalyzeFeature.State()) {
            AnalyzeFeature()
        }
    )
}
