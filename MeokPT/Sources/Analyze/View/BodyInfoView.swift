import SwiftUI

struct BodyInfoView: View {
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
        VStack {
            ForEach(Array(nutritionInfo.enumerated()), id: \.0) { index, item in
                let unit = units[index]
                let maxNutrition = maxNutritionInfo[index]
                
                VStack {
                    HStack {
                        Text("\(item.key)")
                            .font(.headline)
                        Spacer()
                        Text("\(item.value)\(unit) / \(maxNutrition)\(unit)")
                            .font(.caption)
                    }
                    ConditionalProgressView(current: Double(item.value), max: Double(maxNutrition))
                }
                .padding(10)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
                .background(Color.white)
        )
        .padding(24)
    }
}

#Preview {
    BodyInfoView()
}
