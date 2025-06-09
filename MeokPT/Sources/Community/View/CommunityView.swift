import SwiftUI
import ComposableArchitecture
import AlertToast
import Kingfisher

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityFeature>

    var body: some View {
        NavigationStack (path: $store.scope(state: \.path, action: \.path)){
            VStack {
                if store.postItems.isEmpty {
                    VStack {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: store.columns, spacing: 8) {
                            ForEach(store.filteredPosts) { post in
                                Button(action: { store.send(.navigateToPostItemTapped(id: post.id)) }) {
                                    CommunityPostCard(post: post)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                }
            }
            .onAppear { store.send(.onAppear) }
            .navigationTitle("커뮤니티")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button (action: { store.send(.navigateToAddButtonTapped) }) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color("AppSecondaryColor"))
                    }
                    .alert("글을 작성하려면 로그인이 필요합니다.", isPresented: $store.showAlert) {
                        Button("취소", role: .cancel) {}
                        Button("로그인") {
                            store.send(.presentLogin)
                        }
                    }
                }
            }
            .background(Color("AppBackgroundColor"))
            .searchable(text: $store.searchText, prompt: "검색")
        } destination: { storeForElement in
            switch storeForElement.case {
            case .addPost(let writeStore):
                CommunityWriteView(store: writeStore)
                
            case .detailPost(let detailStore):
                CommunityDetailView(store: detailStore)
            }
        }
        .toast(isPresenting: Binding(
            get: { store.showAlertToast },
            set: { _ in }
        )) {
            AlertToast(
                displayMode: .banner(.pop),
                type: store.isSuccess ? .complete(Color("AppSecondaryColor")) : .error(.red),
                title: store.toastMessage,
            )
        }
        .tint(Color("TextButton"))
    }
}

struct CommunityPostCard: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(spacing: 8) {
            Color.clear
                .frame(height: 150)
                .overlay(imageDisplayView)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.placeholderText), lineWidth: 1)
                )

            Text(post.title)
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(minHeight: UIFont.preferredFont(forTextStyle: .headline).lineHeight * 2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(post.dietName)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color("App CardColor"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(uiColor: UIColor.separator), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private var imageDisplayView: some View {
        if !post.photoURL.isEmpty {
            KFImage(URL(string: post.photoURL))
                .placeholder {
                    Image(systemName: "photo")
                        .foregroundStyle(Color.primary.opacity(0.7))
                }
                .resizable()
                .scaledToFill()
        } else {
            Image("CommunityEmptyImage")
                .resizable()
                .scaledToFill()
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
