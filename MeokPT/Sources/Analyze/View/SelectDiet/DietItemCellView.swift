import SwiftUI

struct DietItemCellView: View {
    let diet: Diet
    var isSelected: Bool
    let toggleSelection: () -> Void

    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private func formatValue(_ value: Double?) -> String {
        guard let value = value else { return "-" }
        return numberFormatter.string(from: NSNumber(value: value)) ?? "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack (alignment: .top){
                VStack(alignment: .leading, spacing: 8) {
                    Text(diet.title)
                        .font(.headline)
                    Text("\(formatValue(diet.kcal)) kcal")
                        .font(.subheadline)
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
                DietNutritionInfoCellView(name: "탄수화물", value: "\(formatValue(diet.carbohydrate))g")
                Spacer()
                DietNutritionInfoCellView(name: "단백질", value: "\(formatValue(diet.protein))g")
                Spacer()
                DietNutritionInfoCellView(name: "지방", value: "\(formatValue(diet.fat))g")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected
                      ? Color("AppTertiaryColor").opacity(0.2)
                      : Color("App CardColor"))
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .onTapGesture {
            toggleSelection()
        }
    }
}
