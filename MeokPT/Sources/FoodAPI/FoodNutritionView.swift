//
//  FoodAPIView.swift
//  MeokPT
//
//  Created by 김동영 on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

struct FoodNutritionView: View {
    @Bindable var store: StoreOf<FoodNutritionFeature>

    var body: some View {
        NavigationView {
            Form {
                TextField(
                    "식품 이름 (예: 고구마)",
                    text: $store.foodNameInput.sending(\.foodNameInputChanged)
                )
                .autocapitalization(.none)
                
                Section {
                    Button(action: {
                        store.send(.searchButtonTapped)
                    }) {
                        HStack {
                            Spacer()
                            if store.isLoading {
                                ProgressView()
                            } else {
                                Text("영양 정보 가져오기")
                            }
                            Spacer()
                        }
                    }
                    .disabled(store.isLoading)
                }

                if let foodInfo = store.fetchedFoodInfo {
                    if(foodInfo.DB_CLASS_NM == "품목대표") {
                        Section(header: Text("품목대표")) {
                            Text(foodInfo.foodName)
                            Text("\(foodInfo.calorie, specifier: "%.1f") kcal")
                            NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat).padding()
                        }
                    }
                    if(foodInfo.DB_CLASS_NM == "상용제품") {
                        Section(header: Text("상용제품")) {
                            NutritionDetailRow(label: "식품명", value: foodInfo.FOOD_NM_KR)
                            NutritionDetailRow(label: "열량", value: "\(foodInfo.calorie) kcal")
                            NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat).padding()
                        }
                    }
                }
            }
            .navigationTitle("식품 영양 정보")
        }
    }
}

struct NutritionDetailRow: View {
    let label: String
    let value: String?

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value ?? "N/A")
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    FoodNutritionView(
        store: Store(
            initialState: FoodNutritionFeature.State(foodNameInput: "사과"),
            reducer: { FoodNutritionFeature()._printChanges() }
        )
    )
}
