import SwiftUI

struct DietItemCellView: View {
    let diet: Diet
    var isSelected: Bool
    let toggleSelection: () -> Void
    
    private let displayedNutrients: [NutritionType] = [.carbohydrate, .protein, .fat]


    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private func formatKcal(_ value: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: Int(value.rounded()))) ?? "---"
    }
    
    private func formatNutrient(_ value: Double?) -> String {
        guard let value = value else { return "--.-" }
        return numberFormatter.string(from: NSNumber(value: value)) ?? "--.-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack (alignment: .top){
                VStack(alignment: .leading, spacing: 8) {
                    Text(diet.title)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Text("\(formatKcal(diet.kcal))kcal")
                        .font(.body)
                }
                Spacer()
                Button {
                    toggleSelection()
                } label: {
                    Image(systemName: isSelected ? "checkmark.square" : "square")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            }
            
            HStack(spacing: 20) {
                ForEach(Array(displayedNutrients.enumerated()), id: \.element) { index, nutrientType in
                        DietNutritionInfoCellView(
                            name: nutrientType.rawValue.capitalized,
                            value: diet.formattedNutrient(for: nutrientType)
                        )
                        .frame(maxWidth: .infinity)

                        if index < displayedNutrients.count - 1 {
                            Divider()
                                .frame(height: 40)
                                .padding(.horizontal, 8)
                        }
                    }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected
                      ? Color("AppTertiaryColor").opacity(0.2)
                      : Color("AppCardColor"))
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .onTapGesture {
            toggleSelection()
        }
    }
}
