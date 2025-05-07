import SwiftUI
import ComposableArchitecture

struct DietView: View {
    let store: StoreOf<DietFeature>
    
    var body: some View {
        VStack {
            
        }
    }
}

#Preview {
    DietView(
        store: Store(initialState: DietFeature.State()) {
            DietFeature()
        }
    )
}
