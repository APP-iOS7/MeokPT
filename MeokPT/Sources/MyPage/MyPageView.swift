import SwiftUI
import ComposableArchitecture

struct MyPageView: View {
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

#Preview {
    MyPageView(
        store: Store(initialState: MyPageFeature.State()) {
            MyPageFeature()
        }
    )
}
