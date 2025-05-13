import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    let store: StoreOf<CommunityFeature>

    @State private var searchText: String = ""

    let dummyPosts: [CommunityPost] = [
        .init(title: "오늘의 식단", body: "오늘은 샐러드와 닭가슴살을 먹었습니다.", imageColor: .gray.opacity(0.3)),
        .init(title: "오후 식단", body: "오후엔 단백질 쉐이크로 간단히!", imageColor: .gray.opacity(0.3)),
        .init(title: "오전의 식단", body: "오전엔 바나나 한 개와 계란 두 개!", imageColor: .gray.opacity(0.3)),
        .init(title: "닭가슴살 샐러드", body: "단백질 폭발! 닭가슴살 + 채소 조합", imageColor: .gray.opacity(0.3)),
        .init(title: "햄버거", body: "가끔은 치팅데이도 필요하죠!", imageColor: .gray.opacity(0.3)),
        .init(title: "샐러드 식단", body: "오늘은 채소 중심의 가벼운 식단입니다.", imageColor: .gray.opacity(0.3))
    ]

    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)

    var filteredPosts: [CommunityPost] {
        if searchText.isEmpty {
            return dummyPosts
        } else {
            return dummyPosts.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 🔍 검색창
                TextField("검색", text: $searchText)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding([.horizontal, .top])

                // 📸 게시물 그리드
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredPosts) { post in
                            NavigationLink(destination: CommunityDetailView(
                                postTitle: post.title,
                                postBody: post.body,
                                imageColor: post.imageColor
                            )) {
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
                    }
                    .padding()
                }
            }
            .navigationTitle("커뮤니티")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CommunityWriteView()) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                    }
                }
            }
            .background(Color("AppBackgroundColor"))
        }
    }
}

struct CommunityPost: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let imageColor: Color
}

#Preview {
    CommunityView(
        store: Store(initialState: CommunityFeature.State()) {
            CommunityFeature()
        }
    )
}
