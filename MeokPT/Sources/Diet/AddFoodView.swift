import SwiftUI
import ComposableArchitecture

struct AddFoodView: View {
    @Bindable var store: StoreOf<AddFoodFeature>
    
    private enum NutrientField: Hashable {
        case carbohydrate
        case protein
        case fat
        case dietFiber
        case sugar
        case sodium
    }
    
    private enum NutrientUnit: String {
        case gram = "g"
        case milligram = "mg"
    }
    
    @FocusState private var focusedNutrientField: NutrientField?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                foodInfoSection
                
                Text(store.info ?? "")
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryColor"))
                    .padding(.horizontal, 24)
                
                nutrientSection
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button (action: { store.send(.cancelButtonTapped) }) { Text("취소") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button (action: { store.send(.addButtonTapped) }) { Text("추가") }
                }
            }
            .tint(Color("TextButtonColor"))
            .onTapGesture {
                focusedNutrientField = nil
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onChange(of: focusedNutrientField) { oldValue, newValue in
                switch newValue {
                case .carbohydrate:
                    store.currentCarbohydrates = 0.0
                case .protein:
                    store.currentProtein = 0.0
                case .fat:
                    store.currentFat = 0.0
                case .dietFiber:
                    store.currentDietaryFiber = 0.0
                case .sugar:
                    store.currentSugar = 0.0
                case .sodium:
                    store.currentSodium = 0.0
                case nil:
                    break
                }
            }
        }
    }
    
    @ViewBuilder
    private var foodInfoSection: some View {
        Text(store.selectedFoodItem.foodName)
            .font(.title2)
            .fontWeight(.bold)
        
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                TextField("양", value: $store.amountGram, formatter: NumberFormatter())
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 40, idealWidth: 50, maxWidth: 55)
                    .keyboardType(.numberPad)
                    .onChange(of: store.amountGram) {
                        let amountText = String(store.amountGram)
                        
                        if amountText.count > store.maxInputLength {
                            store.amountGram = Double(amountText.prefix(store.maxInputLength)) ?? 0
                        }
                    }
                Text("g")
                    .font(.body)
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(uiColor: UIColor.separator))
                .padding(.horizontal, 120)
        }
    }
    
    @ViewBuilder
    private var nutrientSection: some View {
        VStack(spacing: 16) {
            Text("\(store.currentCalories, specifier: "%.0f")kcal")
                .foregroundColor(Color("AppSecondaryColor"))
            Spacer().frame(height: 2)
            
            VStack(spacing: 16) {
                HStack {
                    nutrientInputRow(label: "탄수화물", value: $store.currentCarbohydrates, field: .carbohydrate, unit: .gram)
                    Spacer()
                    nutrientInputRow(label: "단백질", value: $store.currentProtein, field: .protein, unit: .gram)
                    Spacer()
                    nutrientInputRow(label: "지방", value: $store.currentFat, field: .fat, unit: .gram)
                }
                
                HStack {
                    nutrientInputRow(label: "식이섬유", value: $store.currentDietaryFiber, field: .dietFiber, unit: .gram)
                    Spacer()
                    nutrientInputRow(label: "당류", value: $store.currentSugar, field: .sugar, unit: .gram)
                    Spacer()
                    nutrientInputRow(label: "나트륨", value: $store.currentSodium, field: .sodium, unit: .milligram)
                }
            }
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
    
    @ViewBuilder
    private func nutrientInputRow(label: String, value: Binding<Double>, field: NutrientField, unit: NutrientUnit) -> some View {
        var nutrientFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            formatter.minimum = 0.0
            formatter.usesGroupingSeparator = false
            if focusedNutrientField == field {
                formatter.minimumFractionDigits = 0
            } else {
                formatter.minimumFractionDigits = 1
            }
            return formatter
        }
        let isFocused = focusedNutrientField == field
        let displayRed = value.wrappedValue == 0 && !isFocused
        let currentForegroundColor = displayRed ? Color.red : Color(.label)

        VStack(alignment: .center, spacing: 12) {
            Text(label)
                .font(.caption)
                .foregroundColor(Color("AppSecondaryColor"))
                .padding(.bottom, -16)
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedNutrientField = field
                    }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    TextField("", value: value, formatter: nutrientFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(currentForegroundColor)
                        .focused($focusedNutrientField, equals: field)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: value.wrappedValue) { oldValue, newValue in
                            if newValue < 0 {
                                value.wrappedValue = 0
                            }
                        }
                    
                    Text(unit.rawValue)
                        .font(.body)
                        .foregroundColor(currentForegroundColor)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.separator))
                .padding(.horizontal, 16)
                .padding(.top, -16)

        }
        .frame(maxWidth: .infinity)
    }
}
