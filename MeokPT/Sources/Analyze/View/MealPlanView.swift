import SwiftUI

struct MealPlanView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("샐러드와 고구마")
                    .font(.headline)
                Text("400kcal")
                    .font(.subheadline)
            }
            
            HStack(spacing: 20) {
                NutrientView(name: "탄수화물", value: "107.5g")
                Spacer()
                NutrientView(name: "단백질", value: "33.3g")
                Spacer()
                NutrientView(name: "지방", value: "8.2g")
            }
            .frame(width: .infinity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
                .background(Color.white)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    MealPlanView()
}
