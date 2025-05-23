import SwiftUI
import ComposableArchitecture

struct DietView: View {
    @Bindable var store: StoreOf<DietFeature>
    @State private var searchText = ""
    @State private var selectedFilter: DietFilter = .all
    
    private var filteredDiets: [Diet] {
        let searchedDiets = searchText.isEmpty ? store.state.dietList.elements : store.state.dietList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        switch selectedFilter {
        case .all:
            return Array(searchedDiets)
        case .favorites:
            return Array(searchedDiets.filter { $0.isFavorite })
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredDiets) { diet in
                Button {
                    store.send(.dietCellTapped(id: diet.id))
                } label: {
                    DietCellView(diet: diet) { id in
                        store.send(.likeButtonTapped(id: id))
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("필터", selection: $selectedFilter) {
                        ForEach(DietFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .listRowSpacing(12)
            .listStyle(.plain)
            .background(Color("AppBackgroundColor"))
            .searchable(text: $searchText, prompt: "검색")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color("AppSecondaryColor"))
    }
}

private enum DietFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case favorites = "즐겨찾기"
    var id: String { self.rawValue }
}

private struct DietCellView: View {
    let diet: Diet
    let onFavoriteToggle: (UUID) -> Void
    private let cornerRadius: CGFloat = 20
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading) {
                HStack(spacing: 16) {
                    Text(diet.title)
                        .font(.headline)
                    Spacer()
                    Toggle("Favorite", isOn: Binding(
                        get: { diet.isFavorite },
                        set: { _ in onFavoriteToggle(diet.id) }
                    ))
                    .toggleStyle(FavoriteToggleStyle())
                    Button {
                        // TODO: 삭제 버튼 만들기
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                Text(String(format: "%.0f kcal", diet.kcal))
            }

            HStack {
                NutrientView(carbohydrate: diet.carbohydrate, protein: diet.protein, fat: diet.fat)
            }
        }
        .padding(24)
        .background(Color("AppCellBackgroundColor"))
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
    }
}

#Preview {
    DietView(
        store: Store(initialState: DietFeature.State(
            dietList: [
                Diet(
                    title: "닭가슴살 샐러드",
                    isFavorite: false,
                    foods: [
                        Food(name: "닭가슴살", amount: 100, kcal: 165, carbohydrate: 0, protein: 31, fat: 3.6),
                        Food(name: "채소믹스", amount: 150, kcal: 35, carbohydrate: 7, protein: 2, fat: 0.5)
                    ]
                ),
                Diet(
                    title: "현미밥과 연어구이",
                    isFavorite: true,
                    foods: [
                        Food(name: "현미밥", amount: 150, kcal: 165, carbohydrate: 36, protein: 3, fat: 1),
                        Food(name: "연어구이", amount: 120, kcal: 250, carbohydrate: 0, protein: 24, fat: 16)
                    ]
                ),
                Diet(
                    title: "두부김치",
                    isFavorite: false,
                    foods: [
                        Food(name: "두부", amount: 200, kcal: 160, carbohydrate: 4, protein: 16, fat: 9),
                        Food(name: "볶음김치", amount: 150, kcal: 120, carbohydrate: 15, protein: 5, fat: 5)
                    ]
                ),
                Diet(
                    title: "고구마와 사과",
                    isFavorite: true,
                    foods: [
                        Food(name: "고구마", amount: 100, kcal: 139, carbohydrate: 32.4, protein: 1.6, fat: 0.2),
                        Food(name: "사과", amount: 150, kcal: 95, carbohydrate: 25, protein: 0.5, fat: 0.3)
                    ]
                )
            ]
        )) {
            DietFeature()
        }
    )
}
