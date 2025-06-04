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
                                isFavorite: favoriteBinding,
                                onRename: { store.send(.renameButtonTapped(id: diet.id)) },
                                onDelete: { store.send(.deleteButtonTapped(id: diet.id)) }
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
                            .foregroundStyle(Color("AppSecondaryColor"))
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
        .tint(Color("TextButton"))
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            "식단 이름 변경",
            isPresented: $store.isRenameAlertPresented,
            actions: {
                TextField("새로운 이름", text: $store.renameInputText)
                Button("변경") {
                    store.send(.confirmRenameTapped)
                }
                Button("취소", role: .cancel) {
                    store.send(.cancelRenameTapped)
                }
            }
        )
        .tint(Color("TextButton"))
    }
}

#Preview {
    DietView(
        store: Store(initialState: DietFeature.State()) {
            DietFeature()
        }
    )
    .modelContainer(for: [Diet.self, Food.self], inMemory: true)
}
