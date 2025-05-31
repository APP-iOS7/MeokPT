import SwiftUI

struct DietItemView: View {
    @Bindable var item: DietItem
    let onMealTypeChange: (DietItem.ID, MealType) -> Void
    
    private let displayedNutrients: [NutritionType] = [.carbohydrate, .protein, .fat]

    var body: some View {
        VStack {
            DietPickerView(item: item, onMealTypeChange: onMealTypeChange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.formattedKcalOnly)
                        .font(.subheadline)
                }

                HStack(spacing: 20) {
                    ForEach(displayedNutrients, id: \.self) { nutrientType in
                        DietNutritionInfoCellView(
                            name: nutrientType.rawValue.capitalized,
                            value: item.formattedNutrient(for: nutrientType)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("App CardColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    DietItemView(item: mockDietItemsForPreview.first!, onMealTypeChange:  { _, _ in })
}
