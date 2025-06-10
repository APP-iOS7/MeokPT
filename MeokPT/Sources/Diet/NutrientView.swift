import SwiftUI

struct NutrientView: View {
    let carbohydrate: Double?
    let protein: Double?
    let fat: Double?
    
    var body: some View {
        HStack {
            EachNutrientView(name: "탄수화물", value: carbohydrate)
                .frame(maxWidth: .infinity)
            Divider()
            EachNutrientView(name: "단백질", value: protein)
                .frame(maxWidth: .infinity)
            Divider()
            EachNutrientView(name: "지방", value: fat)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct EachNutrientView: View {
    let name: String
    let value: Double?
    
    var body: some View {
        VStack(alignment: .center) {
            Text(name)
                .font(.caption)
                .foregroundColor(Color("AppSecondaryColor"))
            Spacer().frame(height:4)
            if let value = value {
                Text(String(format: "%.1f g", value))
                    .font(.body)
            } else {
                Text("--.-")
                    .font(.body)
            }
        }
    }
}

#Preview {
    NutrientView(carbohydrate: 50.0, protein: 20.0, fat: 10.0)
        .padding()
}
