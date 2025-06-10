import SwiftUI

struct DetailNutrientView: View {
    let carbohydrate: Double?
    let protein: Double?
    let fat: Double?
    let dietaryFiber: Double?
    let sugar: Double?
    let sodium: Double?
    
    var body: some View {
        VStack(spacing: 16) {
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
            HStack {
                EachNutrientView(name: "식이섬유", value: dietaryFiber)
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "당류", value: sugar)
                    .frame(maxWidth: .infinity)
                Divider()
                EachNutrientView(name: "나트륨", value: sodium)
                    .frame(maxWidth: .infinity)

            }
        }
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
            Spacer().frame(height: 4)
            
            if let value = value {
                if name == "나트륨" {
                    Text(String(format: "%.1f mg", value))
                        .font(.body)
                } else {
                    Text(String(format: "%.1f g", value))
                        .font(.body)
                }
            } else {
                if name == "나트륨" {
                    Text("--.-")
                        .font(.body)
                } else {
                    Text("--.-")
                        .font(.body)
                }
            }
        }
    }
}


#Preview {
    NutrientView(carbohydrate: 50.0, protein: 20.0, fat: 10.0)
}
