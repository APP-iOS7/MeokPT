import SwiftUI
import ComposableArchitecture

struct DietView: View {
    @Bindable var store: StoreOf<DietFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.filteredDiets) { diet in
                        Button {
                            store.send(.dietCellTapped(id: diet.id))
                        } label: {
                            let favoriteBinding = Binding<Bool>(
                                get: {
                                    store.dietList[id: diet.id]?.isFavorite ?? diet.isFavorite
                                },
                                set: { newValue in
                                    store.send(.likeButtonTapped(id: diet.id, isFavorite: newValue))
                                }
                            )
                            DietCellView(
                                diet: diet,
                                isFavorite: favoriteBinding
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .background(Color("AppBackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("필터", selection: $store.selectedFilter) {
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
            .searchable(text: $store.searchText, prompt: "검색")
            .navigationBarTitleDisplayMode(.inline)
        }
        destination: { storeForElement in
            switch storeForElement.case {
            case .detail(let detailStore):
                DietDetailView(store: detailStore)
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.createDietFullScreenCover, action: \.createDietFullScreenCover)) { store in
            NavigationStack {
                CreateDietView(store: store)
            }
        }
        .tint(Color("AppSecondaryColor"))
    }
}

#Preview {
    DietView(
        store: Store(initialState: DietFeature.State()) {
            DietFeature()
        }
    )
}
