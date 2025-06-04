import SwiftUI
import ComposableArchitecture

struct AddCustomFoodView: View {
    @Bindable var store: StoreOf<AddCustomFoodFeature>
    
    private enum NutrientField: Hashable {
        case kcal
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
        case kcal = "kcal"
    }
    
    @FocusState private var focusedNutrientField: NutrientField?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 48) {
                foodInfoSection
                nutrientSection
            }
            .padding(.horizontal, 24)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button (action: { store.send(.cancelButtonTapped) }) { Text("취소") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button (action: { store.send(.addButtonTapped) }) { Text("추가") }.disabled(!store.checkNameAmount)
                }
            }
            .tint(Color("TextButton"))
            .onTapGesture {
                focusedNutrientField = nil
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    @ViewBuilder
    private var foodInfoSection: some View {
        VStack(alignment: .center) {
            TextField("음식 이름 (필수)", text: $store.foodName)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(uiColor: UIColor.separator))
        }
        .padding(.horizontal, 48)
        
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                TextField("양 (필수)", value: $store.amountGram, formatter: NumberFormatter())
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .onChange(of: store.amountGram) {
                        let amountText = String(store.amountGram ?? 0)
                        
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
        }
        .padding(.horizontal, 120)
    }
    
    @ViewBuilder
    private var nutrientSection: some View {
        VStack(spacing: 16) {
            nutrientInputRow(label: "열량", value: $store.currentCalories, field: .kcal, unit: .kcal)
        
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
    }
    
    @ViewBuilder
    private func nutrientInputRow(label: String, value: Binding<Double?>, field: NutrientField, unit: NutrientUnit) -> some View {
        var nutrientFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = (focusedNutrientField == field) ? 0 : 1
            formatter.maximumFractionDigits = 1
            formatter.minimum = 0.0
            formatter.usesGroupingSeparator = false
            return formatter
        }
        
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
                        .foregroundColor(.primary)
                        .focused($focusedNutrientField, equals: field)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: value.wrappedValue) { _, newValue in
                            guard let unwrappedValue = newValue else { return }

                            if unwrappedValue < 0 {
                                value.wrappedValue = 0
                                return
                            }

                            let numberString = String(unwrappedValue)
                            let components = numberString.components(separatedBy: ".")

                            let integerPart = components[0]
                            let maxIntegerLength = 4

                            if integerPart.count > maxIntegerLength {
                                let trimmedIntegerPart = String(integerPart.prefix(maxIntegerLength))
                                var newStringValue = trimmedIntegerPart
                                
                                // 소수점 이하 처리
                                if components.count > 1 {
                                    let decimalPart = String(components[1].prefix(1))  // 소수점 이하 한 자리만
                                    newStringValue += "." + decimalPart
                                }
                                
                                if let limitedDouble = Double(newStringValue) {
                                    value.wrappedValue = limitedDouble
                                } else {
                                    value.wrappedValue = Double(trimmedIntegerPart) ?? 0
                                }
                            } else if components.count > 1, components[1].count > 1 {
                                // 이미 소수점 이하가 두 자리 이상이라면 잘라내기
                                let decimalPart = String(components[1].prefix(1))
                                let newStringValue = integerPart + "." + decimalPart
                                
                                if let limitedDouble = Double(newStringValue) {
                                    value.wrappedValue = limitedDouble
                                }
                            }
                        }
                    
                    Text(unit.rawValue)
                        .font(.body)
                        .foregroundColor(Color("AppSecondaryColor"))
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.separator))
                .padding(.horizontal, unit == .kcal ? 96 : 16)
                .padding(.top, -16)
        }
        .frame(maxWidth: .infinity)
    }
}
