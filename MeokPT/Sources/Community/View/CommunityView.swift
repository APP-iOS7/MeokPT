import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityFeature>

    var body: some View {
        NavigationStack (path: $store.scope(state: \.path, action: \.path)){
            VStack {
                ScrollView {
                    LazyVGrid(columns: store.columns, spacing: 16) {
                        ForEach(store.filteredPosts) { post in
                                VStack(alignment: .leading, spacing: 8) {
                                    GeometryReader { geometry in
                                        post.imageColor
                                            .frame(width: geometry.size.width, height: geometry.size.width)
                                            .cornerRadius(8)
                                    }
                                    .aspectRatio(1, contentMode: .fit)

                                    Text(post.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("커뮤니티")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button (action: { store.send(.navigateToAddButtonTapped) }) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color("AppSecondaryColor"))
                    }
                }
            }
            .background(Color("AppBackgroundColor"))
            .searchable(text: $store.searchText, prompt: "검색")
        } destination: { storeForElement in
            switch storeForElement.state {
            case .addPost:
                if let AddStore = storeForElement.scope(state: \.addPost, action: \.addPost) {
                    CommunityWriteView(store: AddStore)
                }
            }
        }
        .tint(Color("TextButton"))
    }
}

#Preview {
    CommunityView(
        store: Store(initialState: CommunityFeature.State()) {
            CommunityFeature()
        }
    )
}
