import SwiftUI

struct FoodItem {
    let name: String
    let servingGram: Int
    let calories: Double
    let carbohydrate: Double
    let protein: Double
    let fat: Double
}

struct AddFoodView: View {
    @State private var foodItem = FoodItem(name: "고구마, 찐고구마", servingGram: 200, calories: 139, carbohydrate: 32.4, protein: 1.6, fat: 0.2)
    @State private var amountGram: Int = 200
    private let cornerRadius: CGFloat = 20
    private let maxInputLength = 12

    private var currentCalories: Double {
        (foodItem.calories / Double(foodItem.servingGram)) * Double(amountGram)
    }
    private var currentCarbohydrates: Double {
        (foodItem.carbohydrate / Double(foodItem.servingGram)) * Double(amountGram)
    }
    private var currentProtein: Double {
        (foodItem.protein / Double(foodItem.servingGram)) * Double(amountGram)
    }
    private var currentFat: Double {
        (foodItem.fat / Double(foodItem.servingGram)) * Double(amountGram)
    }
    
    private var info: AttributedString? {
        try? AttributedString(markdown: "식약처에서 제공하는 총 내용량은 **\(foodItem.servingGram)g** 입니다.")
    }


    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(foodItem.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack {
                    TextField("양", value: $amountGram, formatter: NumberFormatter())
                        .foregroundColor(Color("AppSecondaryColor"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .onChange(of: amountGram) {
                            let amountText = String(amountGram)
                                
                            if amountText.count > maxInputLength {
                                amountGram = Int(amountText.prefix(maxInputLength)) ?? 0
                            }
                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(uiColor: UIColor.separator))
                        .padding(.horizontal, 80)
                }
                
                Text(info ?? "")
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryColor"))
                
                VStack(spacing: 16) {
                    Text("\(currentCalories, specifier: "%.0f")kcal")
                    
                    NutrientView(carbohydrate: currentCarbohydrates, protein: currentProtein, fat: currentFat)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .background(Color("AppBackgroundColor"))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                )
                .padding(.horizontal, 24)
            }
            .tint(Color("AppSecondaryColor"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                    }
                    .foregroundColor(.orange)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }
}

#Preview {
    AddFoodView()
}
