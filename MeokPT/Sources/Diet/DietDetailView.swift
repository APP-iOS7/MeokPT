import SwiftUI
import ComposableArchitecture

struct DietDetailView: View {
    @Bindable var store: StoreOf<DietDetailFeature>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
//                    VStack(alignment: .leading) {
//                        HStack {
//                            TextField("제목", text: $store.diet.title.sending(\.updateTitle))
//                            .submitLabel(.done)
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            Spacer()
//                            Toggle("즐겨찾기", isOn: Binding(
//                                get: { store.diet.isFavorite },
//                                set: { _ in store.send(.likeButtonTapped) }
//                            ))
//                            .toggleStyle(FavoriteToggleStyle())
//                            .padding(.horizontal)
//                        }
//                        Text("\(String(format: "%.0f", store.diet.kcal)) kcal")
//                            .font(.title2)
//                    }
                    
//                    HStack {
//                        NutrientView(carbohydrate: store.diet.carbohydrate, protein: store.diet.protein, fat: store.diet.fat)
//                    }
//                    .padding(.horizontal, 32)
                    
                    // 음식 리스트
                    VStack {
                        ForEach(store.foods) { food in
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    Text("\(String(format: "%.0f", food.amount))g, \(String(format: "%.0f", food.kcal))kcal")
                                }
                                NutrientView( carbohydrate: food.carbohydrate, protein: food.protein, fat: food.fat)
                                .padding(.horizontal)
                            }
                            .padding()
                            if food != store.foods.last {
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
                .padding()
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AppBackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("음식 추가") {
                    }
                }
            }
        }
        .tint(Color("AppTintColor"))
    }
}

#Preview {
    DietDetailView(
        store: Store(initialState: DietDetailFeature.State(
            diet: Diet(title: "샐러드와 고구마", kcal: 439, carbohydrate: 37.4, protein: 33.6, fat: 1.2, isFavorite: false),
            foods: [
                Food(name: "닭가슴살 샐러드", amount: 200, kcal: 300, carbohydrate: 5, protein: 32, fat: 1),
                Food(name: "고구마", amount: 100, kcal: 139, carbohydrate: 32.4, protein: 1.6, fat: 0.2)
            ]
        )) {
            DietDetailFeature()
        }
    )
}