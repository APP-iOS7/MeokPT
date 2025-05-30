import SwiftUI

struct DietNotEmptyView: View {
    let dietItems: [DietItem]
    let onMealTypeChange: (DietItem.ID, MealType) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(dietItems) { item in
                    DietItemView(item: item, onMealTypeChange: onMealTypeChange)
                }
            }
        }
    }
}

