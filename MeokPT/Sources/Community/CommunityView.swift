import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityFeature>

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)

    var filteredPosts: [CommunityPost] {
        if store.searchText.isEmpty {
            return dummyPosts
        } else {
            return dummyPosts.filter { $0.title.localizedCaseInsensitiveContains(store.searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔍 검색창
                TextField("검색", text: $store.searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding([.horizontal, .top])

                // 📸 게시물 그리드
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredPosts) { post in
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
                    .padding()
                }
            }
            .navigationTitle("커뮤니티")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                }
            }
            .background(Color("AppBackgroundColor"))
        }
    }
}

#Preview {
    CommunityView(
        store: Store(initialState: CommunityFeature.State()) {
            CommunityFeature()
        }
    )
}
