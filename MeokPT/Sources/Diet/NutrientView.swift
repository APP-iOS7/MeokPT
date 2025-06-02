import SwiftUI

struct NutrientView: View {
    let carbohydrate: Double?
    let protein: Double?
    let fat: Double?
    
    var body: some View {
        HStack {
            EachNutrientView(name: "탄수화물", value: carbohydrate)
            Spacer()
            Divider()
            Spacer()
            EachNutrientView(name: "단백질", value: protein)
            Spacer()
            Divider()
            Spacer()
            EachNutrientView(name: "지방", value: fat)
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
            Spacer().frame(height:4)
            if let value = value {
                if name == "나트륨" {
                    Text("\(value, specifier: "%.1f")mg")
                        .font(.body)
                } else {
                    Text("\(value, specifier: "%.1f")g")
                        .font(.body)
                }
            } else {
                if name == "나트륨" {
                    Text("--.- mg")
                        .font(.body)
                } else {
                    Text("--.- g")
                        .font(.body)
                }
            }
        }
    }
}

#Preview {
    NutrientView(carbohydrate: 50.0, protein: 20.0, fat: 10.0)
        .padding()
}
