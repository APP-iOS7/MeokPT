//
//  CommunityDietSelectView.swift
//  MeokPT
//
//  Created by 김동영 on 6/5/25.
//

import SwiftUI
import ComposableArchitecture

struct CommunityDietSelectView: View {
    var diet: Diet
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(diet.title)
                        .font(.title3.bold())
                        .lineLimit(1)
                    Spacer()
                }
                Spacer().frame(height: 4)
                if (diet.foods.isEmpty) {
                    Text("--- kcal")
                } else {
                    Text(String(format: "%.0f kcal", diet.kcal))
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
