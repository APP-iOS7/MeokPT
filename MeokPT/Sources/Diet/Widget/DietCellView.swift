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
    var kcalString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: diet.kcal)) ?? "\(diet.kcal)"
    }
    @Binding var isFavorite: Bool
    var onRename: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(diet.title)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Spacer()
                    Toggle("Favorite", isOn: $isFavorite)
                        .toggleStyle(FavoriteToggleStyle())
                    Menu {
                        Button("이름 변경", action: onRename)
                        Button("삭제", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color("AppSecondaryColor"))
                            .frame(width: 24, height: 24) // 터치 영역 확보
                    }
                }
                Spacer().frame(height: 4)
                if (diet.foods.isEmpty) {
                    Text("--- kcal")
                } else {
                    Text("\(kcalString) kcal")
                        .font(.body)
                }
            }
            Spacer().frame(height: 8)
            HStack {
                if (diet.foods.isEmpty) {
                    EmptyNutrientView()
                } else {
                    NutrientView(carbohydrate: diet.carbohydrate, protein: diet.protein, fat: diet.fat)
                }
            }
        }
        .padding(24)
        .background(Color(UIColor.secondarySystemGroupedBackground))
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
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(width: 24, height: 24)
                )
        }
        .foregroundColor(Color("AppSecondaryColor"))
        .buttonStyle(.plain)
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
        isFavorite: $isFavoritePreview,
        onRename: { print("Rename tapped") },
        onDelete: { print("Delete tapped") }
    )
    .padding()
    .frame(height: 162)
}
