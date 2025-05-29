//
//  DietCellView.swift
//
//
//  Created by 김동영 on 5/23/25.
//
import SwiftUI
import ComposableArchitecture

struct DietCellView: View {    
    var diet: Diet
    @Binding var isFavorite: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(diet.title)
                        .font(.headline)
                    Spacer()
                    Toggle("Favorite", isOn: $isFavorite)
                        .toggleStyle(FavoriteToggleStyle())
                    Button {
                        // TODO: 삭제 버튼 만들기
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                Spacer().frame(height: 4)
                Text(String(format: "%.0f kcal", diet.kcal))
                    .font(.body)
            }
            Spacer().frame(height: 8)
            HStack {
                NutrientView(carbohydrate: diet.carbohydrate, protein: diet.protein, fat: diet.fat)
            }
        }
        .padding(24)
        .background(Color("AppCellBackgroundColor"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
    }
}

struct FavoriteToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "heart.fill" : "heart")
        }
        .foregroundColor(Color("AppSecondaryColor"))
    }
}

#Preview {
    @Previewable @State var isFavoritePreview: Bool = false
    DietCellView(
        diet: Diet(
            title: "샐러드와 고구마",
            isFavorite: false,
            foods: [
                Food(name: "닭가슴살 샐러드", amount: 200, kcal: 300, carbohydrate: 5, protein: 32, fat: 1, dietaryFiber: 2, sodium: 4, sugar: 5),
                Food(name: "고구마", amount: 100, kcal: 301390, carbohydrate: 32.4, protein: 1.6, fat: 0.2, dietaryFiber: 4.1, sodium: 1.1, sugar: 2.2),
            ]
        ),
        isFavorite: $isFavoritePreview
    )
    .padding()
    .frame(height: 162)
}
