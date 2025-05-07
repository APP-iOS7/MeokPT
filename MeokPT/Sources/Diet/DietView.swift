import SwiftUI
import ComposableArchitecture

struct DietView: View {
    let store: StoreOf<DietFeature>
    
    var body: some View {
        VStack {
            
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
