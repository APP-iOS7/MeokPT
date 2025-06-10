import SwiftUI

struct DailyNutritionInfoView: View {
    var nutritionItems: [NutritionItem]
    
    var body: some View {
        VStack {
            ForEach(nutritionItems.filter { $0.max != 0 }) { item in
                VStack {
                    HStack {
                        Text("\(item.name)")
                            .font(.headline)
                        Spacer()
                        Text("\(item.value)\(item.unit) / \(item.max)\(item.unit)")
                            .font(.caption)
                    }
                    ConditionalProgressView(current: Double(item.value), max: Double(item.max))
                }
                .padding(10)
            }
        }
        .padding(24)
        .cornerRadius(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(24)
    }
}

//#Preview {
//    DailyNutritionInfoView(nutritionItems: mockNutritionItems)
//}
