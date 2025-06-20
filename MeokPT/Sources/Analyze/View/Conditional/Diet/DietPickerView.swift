import SwiftUI

struct DietPickerView: View {
    let item: DietItem
    let onMealTypeChange: (UUID, MealType) -> Void

    var body: some View {
        Picker("식단 종류 선택 \(item.name)", selection: Binding<MealType>(
            get: { item.mealType ?? .none },
            set: { newMealType in
                item.mealType = newMealType
                onMealTypeChange(item.id, newMealType)
            }
        )) {
            ForEach(MealType.allCases, id: \.self) { meal in
                Text(meal.rawValue.capitalized).tag(meal)
                    .font(.title3)
            }
        }
        .tint(Color("App ProfileColor"))
        .background(.clear)
    }
}
