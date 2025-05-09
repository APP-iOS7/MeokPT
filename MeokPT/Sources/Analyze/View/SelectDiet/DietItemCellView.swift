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
                NutrientView(name: "탄수화물", value: "107.5g")
                Spacer()
                NutrientView(name: "단백질", value: "33.3g")
                Spacer()
                NutrientView(name: "지방", value: "8.2g")
            }
            .frame(width: .infinity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color("AppTertiaryColor").opacity(0.2) : Color.white)
                .stroke(Color.gray, lineWidth: 1)
                .background(Color.white)
        )
        .padding(.horizontal, 24)
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

//#Preview {
//    DietItemCell(isSelected: Bindi false)
//}
