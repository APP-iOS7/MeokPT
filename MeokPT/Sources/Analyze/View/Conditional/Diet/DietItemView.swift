import SwiftUI

struct DietItemView: View {
    @Bindable var item: DietItem
    let onMealTypeChange: (DietItem.ID, MealType) -> Void
    
    private let displayedNutrients: [NutritionType] = [.carbohydrate, .protein, .fat, .dietaryFiber, .sugar , .sodium]

    var body: some View {
        VStack {
            DietPickerView(item: item, onMealTypeChange: onMealTypeChange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Text(item.formattedKcalOnlySafe)
                        .font(.body)
                }

                VStack(spacing: 16) {
                    ForEach(0..<2, id: \.self) { row in
                        let rowItems = Array(displayedNutrients[row * 3..<min((row + 1) * 3, displayedNutrients.count)])
                        HStack(spacing: 20) {
                            ForEach(Array(rowItems.enumerated()), id: \.element) { index, nutrientType in
                                DietNutritionInfoCellView(
                                    name: nutrientType.rawValue.capitalized,
                                    value: item.formattedNutrientSafe(for: nutrientType)
                                )
                                .frame(maxWidth: .infinity)

                                if index < rowItems.count - 1 {
                                    Divider()
                                        .frame(height: 40)
                                        .padding(.horizontal, 8)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("App CardColor"))
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.top, 5)
            .padding(.bottom, 24)
        }
    }
}
