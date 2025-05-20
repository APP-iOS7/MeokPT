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
                Section(header: Text("검색 정보")) {
                    TextField(
                        "식품 이름 (예: 고구마)",
                        text: $store.foodNameInput.sending(\.foodNameInputChanged)
                    )
                    .autocapitalization(.none)
                    
                    HStack {
                        Text("DB 구분명")
                        Spacer()
                        Text(store.dbClassNameInput)
                            .foregroundColor(.gray)
                    }
                }

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
                    Section(header: Text("영양 정보 (\(foodInfo.FOOD_NM_KR ?? "알 수 없음"))")) {
                        NutritionDetailRow(label: "식품명", value: foodInfo.FOOD_NM_KR)
                        NutritionDetailRow(label: "DB 구분", value: foodInfo.DB_CLASS_NM)
                        NutritionDetailRow(label: "열량", value: foodInfo.displayCalorie)
                        NutritionDetailRow(label: "단백질", value: foodInfo.displayProtein)
                        NutritionDetailRow(label: "지방", value: foodInfo.displayFat)
                        NutritionDetailRow(label: "탄수화물", value: foodInfo.displayCarbohydrate)
                        NutritionDetailRow(label: "총식이섬유", value: foodInfo.dietaryFiber)
                        NutritionDetailRow(label: "나트륨", value: foodInfo.sodium)
                        NutritionDetailRow(label: "1회 제공량", value: foodInfo.servingSize)
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
            initialState: FoodNutritionFeature.State(foodNameInput: "사과", dbClassNameInput: "품목대표"),
            reducer: { FoodNutritionFeature()._printChanges() }
        )
    )
}
