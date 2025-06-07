import SwiftUI
import ComposableArchitecture
import AlertToast

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityFeature>

    var body: some View {
        NavigationStack (path: $store.scope(state: \.path, action: \.path)){
            VStack {
            }
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
            switch storeForElement.state {
            case .addPost:
                if let AddStore = storeForElement.scope(state: \.addPost, action: \.addPost) {
                    CommunityWriteView(store: AddStore)
                }
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

#Preview {
    CommunityView(
        store: Store(initialState: CommunityFeature.State()) {
            CommunityFeature()
        }
    )
}
