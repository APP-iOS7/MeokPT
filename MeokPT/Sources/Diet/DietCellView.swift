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
                Text(String(format: "%.0f kcal", diet.kcal))
            }
            
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
