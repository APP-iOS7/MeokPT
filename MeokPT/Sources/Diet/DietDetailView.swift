import SwiftUI
import ComposableArchitecture

struct DietDetailView: View {
    @Bindable var store: StoreOf<DietDetailFeature>
    
    @FocusState private var titleFocusedField: Bool
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                nutritionSummarySection
                foodListSection
                if store.diet.foods.isEmpty {
                    Text("음식을 추가해 주세요")
                        .foregroundStyle(Color.secondary)
                        .padding(.top, 48)
                }
            }
            .padding(24)
        }
        .onTapGesture {
            titleFocusedField = false
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color("AppBackgroundColor"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("음식 추가") {
                    editMode?.wrappedValue = .inactive
                    store.send(.addFoodButtonTapped)
                }
            }
        }
        .fullScreenCover(item: $store.scope(state: \.createDietFullScreenCover, action: \.createDietFullScreenCover)) { store in
            NavigationStack {
                CreateDietView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.editFoodSheet, action: \.editFoodSheet)) { store in
            EditFoodView(store: store)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.8)])
        }
        .tint(Color("TextButton"))
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
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
        }
    }
    
    private var nutritionSummarySection: some View {
        Group {
            if !store.diet.foods.isEmpty {
                populatedNutritionView
            } else {
                emptyNutritionView
            }
        }
    }
    
    private var populatedNutritionView: some View {
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
    }
    
    private var emptyNutritionView: some View {
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
    
    private var foodListSection: some View {
        VStack {
            ForEach(Array(store.diet.foods.enumerated()), id: \.element.id) { index, food in
                FoodItemRow(
                    food: food,
                    index: index,
                    editMode: editMode,
                    isLast: food == store.diet.foods.last,
                    onDelete: { store.send(.deleteFood(at: IndexSet(integer: index))) },
                    onTap: { store.send(.foodCellTapped(food)) }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: store.diet.foods.count)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
    }
}

// MARK: - Food Item Row

private struct FoodItemRow: View {
    let food: Food
    let index: Int
    let editMode: Binding<EditMode>?
    let isLast: Bool
    let onDelete: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if editMode?.wrappedValue.isEditing == true {
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                    }
                    .padding(.leading)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                
                foodContentView
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if editMode?.wrappedValue.isEditing != true {
                            onTap()
                        }
                    }
            }
            .transition(.asymmetric(
                insertion: .slide.combined(with: .opacity),
                removal: .slide.combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: editMode?.wrappedValue)
            
            if !isLast {
                Divider()
            }
        }
    }
    
    private var foodContentView: some View {
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
    .modelContainer(for: [Diet.self, Food.self], inMemory: true)
}

