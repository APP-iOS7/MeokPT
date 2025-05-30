import SwiftUI

struct DietItemCellView: View {
    @Binding var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack (alignment: .top){
                VStack(alignment: .leading, spacing: 8) {
                    Text("샐러드와 고구마")
                        .font(.headline)
                    Text("400kcal")
                        .font(.subheadline)
                }
                Spacer()
                Button {
                    isSelected.toggle()
                } label: {
                    Image(systemName: isSelected ? "checkmark.square" : "square")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            }
            
            HStack(spacing: 20) {
                DietNutritionInfoCellView(name: "탄수화물", value: "107.5g")
                Spacer()
                DietNutritionInfoCellView(name: "단백질", value: "33.3g")
                Spacer()
                DietNutritionInfoCellView(name: "지방", value: "8.2g")
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
            isSelected.toggle()
        }
    }
}
