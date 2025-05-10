import SwiftUI
import ComposableArchitecture

struct DietView: View {
    let store: StoreOf<DietFeature>
    
    var body: some View {
        VStack {
            Button(action: {
                store.send(.goDietDetailViewAction)
            }) {
                Text("상세페이지")
                    .foregroundStyle(Color("AppTintColor"))
            }
        }
        .containerRelativeFrame([.horizontal, .vertical])
        .background(Color("AppBackgroundColor"))
    }
}

#Preview {
    DietView(
        store: Store(initialState: DietFeature.State()) {
            DietFeature()
        }
    )
}
