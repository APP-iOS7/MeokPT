import SwiftUI
import ComposableArchitecture

struct CommunityDetailView: View {
    @Bindable var store: StoreOf<CommunityDetailFeature>

    var body: some View {
        ScrollView {
            VStack {
                Text("")
            }
        }
        .navigationTitle(store.communityPost.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("AppBackgroundColor"))
    }
}

#Preview {
    CommunityDetailView(
        store: Store(initialState: CommunityDetailFeature.State(
            communityPost: dummyCommunityPost
        )) {
            CommunityDetailFeature()
        }
    )
}
