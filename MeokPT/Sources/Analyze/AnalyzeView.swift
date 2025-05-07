import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    let store: StoreOf<AnalyzeFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("분석")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AnalyzeView(
        store: Store(initialState: AnalyzeFeature.State()) {
            AnalyzeFeature()
        }
    )
}
