import SwiftUI
import ComposableArchitecture

struct EditFoodView: View {
    @Bindable var store: StoreOf<EditFoodFeature>
    
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
                
                Text("음식 정보를 수정할 수 있습니다.")
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryColor"))
                    .padding(.horizontal, 24)
                
                nutrientSection
                
                if(store.isNutrientEmpty) {
                    HStack {
                        Text("- 로 표시된 영양성분은 식약처 DB에서 제공하지 않습니다. 수정이 가능합니다.")
                    }
                    .font(.caption)
                    .foregroundColor(Color("AppSecondaryColor"))
                    .padding(.horizontal, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button (action: { store.send(.cancelButtonTapped) }) { Text("취소") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button (action: { store.send(.saveButtonTapped) }) { Text("저장") }
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
        Text(store.food.name)
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
                    nutrientInputRow(label: "탄수화물", value: $store.currentCarbohydrates, field: .carbohydrate, unit: .gram, isAvailable: store.isCarbohydratesAvailable)
                    Spacer()
                    nutrientInputRow(label: "단백질", value: $store.currentProtein, field: .protein, unit: .gram, isAvailable: store.isProteinAvailable)
                    Spacer()
                    nutrientInputRow(label: "지방", value: $store.currentFat, field: .fat, unit: .gram, isAvailable: store.isFatAvailable)
                }
                
                HStack {
                    nutrientInputRow(label: "식이섬유", value: $store.currentDietaryFiber, field: .dietFiber, unit: .gram, isAvailable: store.isDietaryFiberAvailable)
                    Spacer()
                    nutrientInputRow(label: "당류", value: $store.currentSugar, field: .sugar, unit: .gram, isAvailable: store.isSugarAvailable)
                    Spacer()
                    nutrientInputRow(label: "나트륨", value: $store.currentSodium, field: .sodium, unit: .milligram, isAvailable: store.isSodiumAvailable)
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
    private func nutrientInputRow(label: String, value: Binding<Double?>, field: NutrientField, unit: NutrientUnit, isAvailable: Bool) -> some View {
        var nutrientFormatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = (focusedNutrientField == field) ? 0 : 1
            formatter.maximumFractionDigits = 1
            formatter.minimum = 0.0
            formatter.usesGroupingSeparator = false
            return formatter
        }
        let isFocused = focusedNutrientField == field
        
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
                        if !isAvailable {
                            value.wrappedValue = 0.0
                        }
                    }
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    ZStack {
                        // 실제 편집용 TextField
                        TextField("", value: value, formatter: nutrientFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .foregroundColor(isFocused ? .black : .clear)
                            .focused($focusedNutrientField, equals: field)
                            .fixedSize(horizontal: true, vertical: false)
                            .onChange(of: value.wrappedValue) { _, newValue in
                                guard let unwrappedValue = newValue else { return }
                                onChangeValue(unwrappedValue, value)
                            }
                        
                        // 표시용 텍스트 (포커스되지 않았을 때)
                        if !isFocused {
                            Text(isAvailable ? String(format: "%.1f", value.wrappedValue ?? 0.0) : "--.-")
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: true, vertical: false)
                                .allowsHitTesting(false)
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
                .padding(.horizontal, 16)
                .padding(.top, -16)

        }
        .frame(maxWidth: .infinity)
    }
}
