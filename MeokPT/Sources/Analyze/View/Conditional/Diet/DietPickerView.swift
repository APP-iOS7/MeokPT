import SwiftUI

struct DietPickerView: View {
    let item: DietItem
    let onMealTypeChange: (UUID, MealType) -> Void

    var body: some View {
        Picker("식단 종류 선택 \(item.name)", selection: Binding<MealType>(
            get: { item.mealType ?? .breakfast },
            set: { newMealType in onMealTypeChange(item.id, newMealType) }
        )) {
            ForEach(MealType.allCases, id: \.self) { meal in
                Text(meal.rawValue.capitalized).tag(meal)
            }
        }
    }
}
