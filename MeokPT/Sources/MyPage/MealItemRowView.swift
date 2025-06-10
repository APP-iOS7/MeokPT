//
//  MealComponents.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import SwiftUI

struct MealItemRowView: View {
    let meal: ParsedMeal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.displayTitle)
                    .font(.title3.bold())
                Text("\(String(format: "%.0f", meal.calories))kcal")
                    .font(.body)
            }
            VStack(spacing: 16) {
                HStack {
                    NutrientItemView(name: "탄수화물", value: meal.carbohydrates, unit: "g")
                        .frame(maxWidth: .infinity)
                    Divider()
                    NutrientItemView(name: "단백질", value: meal.protein, unit: "g")
                        .frame(maxWidth: .infinity)
                    Divider()
                    NutrientItemView(name: "지방", value: meal.fat, unit: "g")
                        .frame(maxWidth: .infinity)
                }
                HStack {
                    NutrientItemView(name: "식이섬유", value: meal.dietaryFiber, unit: "g")
                        .frame(maxWidth: .infinity)
                    Divider()
                    NutrientItemView(name: "당류", value: meal.sugar, unit: "g")
                        .frame(maxWidth: .infinity)
                    Divider()
                    NutrientItemView(name: "나트륨", value: meal.sodium, unit: "mg")
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct NutrientItemView: View {
    let name: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("\(String(format: "%.1f", value)) \(unit)")
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}
