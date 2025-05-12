import SwiftUI

struct SearchedFood: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let calories: Double
    let carbohydrate: Double
    let protein: Double
    let fat: Double
    let category: FoodCategory
}

enum FoodCategory: String, CaseIterable, Identifiable {
    case representative = "품목대표"
    case commercialProduct = "상용제품"
    
    var id: String { self.rawValue }
    static var sorted: [FoodCategory] {
        [.representative, .commercialProduct]
    }
}

struct AddDietView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    @State private var foods: [SearchedFood] = [
        SearchedFood(name: "고구마, 군고구마", calories: 139, carbohydrate: 32.4, protein: 1.6, fat: 0.2, category: .representative),
        SearchedFood(name: "사과, 부사 (중간 크기)", calories: 95, carbohydrate: 25, protein: 0.5, fat: 0.3, category: .representative),
        SearchedFood(name: "닭가슴살, 구운 것 (100g)", calories: 165, carbohydrate: 0, protein: 31, fat: 3.6, category: .representative),
        SearchedFood(name: "고구마스틱 (시판)", calories: 150, carbohydrate: 25, protein: 2, fat: 5, category: .commercialProduct),
        SearchedFood(name: "단백질 바 (평균)", calories: 200, carbohydrate: 22, protein: 20, fat: 8, category: .commercialProduct),
        SearchedFood(name: "아몬드 한 줌 (약 23알)", calories: 160, carbohydrate: 6, protein: 6, fat: 14, category: .commercialProduct)
    ]

    private var groupedFoods: [FoodCategory: [SearchedFood]] {
        Dictionary(grouping: foods, by: { $0.category })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        TextField("음식 검색", text: $searchText)
                            .textFieldStyle(.plain)
                            .submitLabel(.search)
                            .onSubmit {
                            }
                        Divider()
                    }
                    
                    Button {
                        // TODO: 바코드 스캔 기능 구현
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title)
                    }
                }
                .padding(.horizontal, 24)

                if foods.isEmpty && !searchText.isEmpty {
                    Spacer()
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    SearchResultView(groupedFoods: groupedFoods)
                }
            }
            .navigationTitle("식단 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        // TODO: 화면 닫기
                        dismiss()
                    }
                    .tint(Color("AppTintColor"))
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbarBackground(Color("AppBackgroundColor"), for: .navigationBar)
            .background(Color("AppBackgroundColor"))
            .tint(Color("AppSecondaryColor"))
        }
    }
}

private struct SearchResultView: View {
    var groupedFoods: [FoodCategory: [SearchedFood]]
    private var displayedCategories: [FoodCategory] {
        FoodCategory.sorted.filter {
            groupedFoods.keys.contains($0)
        }
    }
    private let cornerRadius: CGFloat = 20
    
    @State private var selectedFood: SearchedFood?
    @State private var isShowingFoodDetailSheet = false
    
    var body: some View {
        List(displayedCategories) { category in
            Section {
                VStack(spacing: 0) {
                    ForEach(groupedFoods[category] ?? []) { food in
                        FoodCellView(food: food)
                            .onTapGesture {
                                self.selectedFood = food
                                self.isShowingFoodDetailSheet = true
                            }
                        if food.id != groupedFoods[category]?.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color("AppCellBackgroundColor"))
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
                )
            } header: {
                HStack {
                    Text(category.rawValue)
                        .font(.subheadline)
                    Spacer()
                    Text("영양성분은 100g 기준입니다")
                        .font(.subheadline)
                }
                .foregroundStyle(Color("AppSecondaryColor"))
                .textCase(nil)
                .padding(.horizontal)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .sheet(isPresented: $isShowingFoodDetailSheet) {
            if let food = selectedFood {
                // TODO: 용량 지정 뷰
                Text("\(food.name) 선택됨. 용량 지정 화면 표시 예정.")
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct FoodCellView: View {
    let food: SearchedFood
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                Text(food.name)
                    .font(.headline)
                Text(String(format: "%.0f kcal", food.calories))
            }
            
            NutrientView(carbohydrate: food.carbohydrate, protein: food.protein, fat: food.fat)
        }
        .padding()
    }
}

#Preview {
    AddDietView()
}
