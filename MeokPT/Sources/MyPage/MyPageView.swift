import SwiftUI
import ComposableArchitecture

struct MyPageView: View {
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    store.send(.loginSignUpButtonTapped)
                }) {
                    Text("회원가입/로그인")
                        .foregroundStyle(Color("AppTintColor"))
                }
            }
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
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
