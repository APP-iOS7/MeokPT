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
    
    @FocusState private var focusedField: Bool

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        TextField(
                            "",
                            text: $store.foodNameInput.sending(\.foodNameInputChanged),
                            prompt: Text("식품 이름 (예: 고구마)")
                        )
                        .focused($focusedField)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.placeholderText))
                    }
                    Spacer()
                    Button(action: {
                        store.send(.searchButtonTapped)
                    }) {
                        if store.isLoading {
                            ProgressView()
                        } else {
                            Text("검색")
                        }
                    }
                    .disabled(store.isLoading)
                }
                Spacer().frame(height:24)
                if let foodInfo = store.fetchedFoodInfo {
                    if(foodInfo.DB_CLASS_NM == "품목대표") {
                        VStack {
                            HStack{
                                Text("품목대표")
                                Spacer()
                                Text("영양성분은 100g 기준입니다.")
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color("AppSecondaryColor"))
                            VStack(alignment: .leading) {
                                Text(foodInfo.foodName).font(.headline).fontWeight(.bold)
                                Spacer().frame(height:4)
                                Text("\(foodInfo.calorie, specifier: "%.0f")kcal").font(.body)
                                Spacer().frame(height: 20)
                                NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat)
                                    .frame(height: 47)
                                    .padding(.horizontal)
                            }
                            .padding(24)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(UIColor.separator), lineWidth: 1)
                            )
                        }
                    }
                    if(foodInfo.DB_CLASS_NM == "상용제품") {
                        VStack {
                            HStack{
                                Text("상용제품")
                                Spacer()
                                Text("영양성분은 100g 기준입니다.")
                                    .fontWeight(.bold)
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color("AppSecondaryColor"))
                            VStack(alignment: .leading) {
                                Text(foodInfo.foodName).font(.headline).fontWeight(.bold)
                                Spacer().frame(height:4)
                                Text("\(foodInfo.calorie, specifier: "%.0f")kcal").font(.body)
                                Spacer().frame(height: 20)
                                NutrientView(carbohydrate: foodInfo.carbohydrate, protein: foodInfo.protein, fat: foodInfo.fat)
                                    .frame(height: 47)
                                    .padding(.horizontal)
                            }
                            .padding(24)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(UIColor.separator), lineWidth: 1)
                            )
                        }
                    }
                }
                Spacer()
            }
            .padding(24)
            .navigationTitle("식단 생성")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = false
            }
            .background(Color("AppBackgroundColor"))
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
