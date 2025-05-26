import SwiftUI
import ComposableArchitecture

struct AddFoodView: View {
    @Bindable var store: StoreOf<AddFoodFeature>

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(store.selectedFoodItem.foodName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack {
                    TextField("양", value: $store.amountGram, formatter: NumberFormatter())
                        .foregroundColor(Color("AppSecondaryColor"))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .onChange(of: store.amountGram) {
                            let amountText = String(store.amountGram)
                                
                            if amountText.count > store.maxInputLength {
                                store.amountGram = Int(amountText.prefix(store.maxInputLength)) ?? 0
                            }
                        }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(uiColor: UIColor.separator))
                        .padding(.horizontal, 80)
                }
                
                Text(store.info ?? "")
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryColor"))
                    .padding(.horizontal, 24)
                
                VStack(spacing: 16) {
                    Text("\(store.currentCalories, specifier: "%.0f")kcal")
                    
                    NutrientView(carbohydrate: store.currentCarbohydrates, protein: store.currentProtein, fat: store.currentFat)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(24)
                .background(Color("AppBackgroundColor"))
                .cornerRadius(store.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: store.cornerRadius)
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
