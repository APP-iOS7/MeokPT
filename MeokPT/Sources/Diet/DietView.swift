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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List(filteredDiets) { diet in
                ZStack {
                    NavigationLink(
                        state: DietFeature.Path.State.detail(
                            .init(
                                diet: diet,
                                foods: Diet.sampleFoods(for: diet.title)
                            )
                        )
                    ) {
                        EmptyView() // NavigationLink의 label을 비워서 기본 '>' 표시가 나타나지 않도록 함
                    }

                    DietCellView(diet: diet) { id in
                        store.send(.likeButtonTapped(id: id))
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
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
        } destination: { store in
            switch store.state {
            case .detail:
                if let detailStore = store.scope(state: \.detail, action: \.detail) {
                    DietDetailView(store: detailStore)
                }
            }
        }
        .tint(Color("AppSecondaryColor"))
        .onAppear {
//            store.send(.onAppear)
        }
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
        store: Store(initialState: DietFeature.State()) {
            DietFeature()
        }
    )
}
