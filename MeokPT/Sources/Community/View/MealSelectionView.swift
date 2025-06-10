import SwiftUI
import ComposableArchitecture

struct MealSelectionView: View {
    @Bindable var store: StoreOf<MealSelectionFeature>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.currentDietList) { diet in
                    CommunityDietSelectView(diet: diet)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.send(.dietCellTapped(id: diet.id))
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle("식단 선택")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
        .searchable(text: $store.searchText, prompt: "검색")
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    store.send(.dismissButtonTapped)
                } label: {
                    Text("취소").foregroundStyle(Color("TextButton"))
                }
            }
            ToolbarItemGroup(placement: .principal) {
                Picker("정렬", selection: $store.selectedFilter) {
                    ForEach(DietFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    store.send(.favoriteFilterButtonTapped)
                } label: {
                    Image(systemName: store.isFavoriteFilterActive ? "heart.fill" : "heart")
                        .foregroundStyle(Color("TextButton"))
                }
            }
        }
    }
}
