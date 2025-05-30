import SwiftUI
import ComposableArchitecture

struct DietDetailView: View {
    @Bindable var store: StoreOf<DietDetailFeature>
    
    @FocusState private var titleFocusedField: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        TextField(
                            "제목",
                            text: Binding(
                                get: { store.diet.title },
                                set: { store.send(.updateTitle($0)) }
                            )
                        )
                        .focused($titleFocusedField)
                        .submitLabel(.done)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                        Spacer()

                        Toggle(
                            "즐겨찾기",
                            isOn: Binding(
                                get: { store.diet.isFavorite },
                                set: { _ in store.send(.likeButtonTapped) }
                            )
                        )
                        .toggleStyle(FavoriteToggleStyle())
                    }
                    if(!store.diet.foods.isEmpty) {
                        VStack {
                            VStack {
                                HStack {
                                    Text("총 열량")
                                        .foregroundStyle(Color("AppSecondaryColor"))
                                    Spacer()
                                    Text("\(String(format: "%.0f", store.diet.kcal)) kcal")
                                }
                                .font(.body)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.placeholderText))
                            }
                            .padding(.horizontal, 8)
                            Spacer().frame(height: 24)
                            HStack {
                                DetailNutrientView(
                                    carbohydrate: store.diet.carbohydrate,
                                    protein: store.diet.protein,
                                    fat: store.diet.fat,
                                    dietaryFiber: store.diet.dietaryFiber,
                                    sugar: store.diet.sugar,
                                    sodium: store.diet.sodium
                                )
                            }
                        }
                    } else {
                        VStack {
                            VStack {
                                HStack {
                                    Text("총 열량")
                                        .foregroundStyle(Color("AppSecondaryColor"))
                                    Spacer()
                                    Text("--- kcal")
                                }
                                .font(.body)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(.placeholderText))
                            }
                            .padding(.horizontal, 8)
                            Spacer().frame(height: 24)
                            HStack {
                                EmptyDetailNutrientView()
                            }
                        }
                    }
                }

                VStack {
                    ForEach(store.diet.foods) { food in
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(food.name)
                                    .font(.headline)
                                Text("\(String(format: "%.0f", food.amount))g, \(String(format: "%.0f", food.kcal))kcal")
                            }
                            .padding(24)
                            DetailNutrientView(
                                carbohydrate: food.carbohydrate,
                                protein: food.protein,
                                fat: food.fat,
                                dietaryFiber: food.dietaryFiber,
                                sugar: food.sugar,
                                sodium: food.sodium
                            )
                            .padding(.bottom, 24)
                        }
                        if food != store.diet.foods.last {
                            Divider()
                        }
                    }
                }
                .background(Color("AppCellBackgroundColor"))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                )
            }
            .padding(.horizontal, 24)
        }
        .onTapGesture {
            titleFocusedField = false
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color("AppBackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("음식 추가") {
                    store.send(.addFoodButtonTapped)
                }
            }
        }
        .fullScreenCover(item: $store.scope(state: \.createDietFullScreenCover, action: \.createDietFullScreenCover)) { store in
            NavigationStack {
                CreateDietView(store: store)
            }
        }
        .tint(Color("TextButton"))
    }
}

#Preview {
    NavigationStack {
        DietDetailView(
            store: Store(
                initialState: DietDetailFeature.State(
                    diet: Diet(
                        title: "샐러드와 고구마",
                        isFavorite: false,
                        foods: [
                            Food(name: "닭가슴살 샐러드", amount: 200, kcal: 300, carbohydrate: 5, protein: 32, fat: 1, dietaryFiber: 2, sodium: 4, sugar: 5),
                            Food(name: "고구마", amount: 100, kcal: 390, carbohydrate: 32.4, protein: 1.6, fat: 0.2, dietaryFiber: 4.1, sodium: 1.1, sugar: 2.2),
                        ]
                    ),
                    dietID: UUID()
                )
            ) {
                DietDetailFeature()
            }
        )
    }
}

