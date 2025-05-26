import SwiftUI
import ComposableArchitecture

struct DietView: View {
    @Bindable var store: StoreOf<DietFeature>
    
    var body: some View {
        NavigationStack {
            List(store.filteredDiets) { diet in
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
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24))
                }
            }
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
            .listRowSpacing(12)
            .listStyle(.plain)
            .background(Color("AppBackgroundColor"))
            .searchable(text: $store.searchText, prompt: "검색")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(
            item: $store.scope(state: \.addDietFullScreenCover, action: \.addDietFullScreenCover)) { store in
            NavigationStack {
                FoodNutritionView(store: store)
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
