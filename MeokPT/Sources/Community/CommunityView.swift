import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    let store: StoreOf<CommunityFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("커뮤니티")
            .navigationBarTitleDisplayMode(.inline)
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
