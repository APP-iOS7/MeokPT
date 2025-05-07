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
            .containerRelativeFrame([.horizontal, .vertical])
            .background(Color("AppBackgroundColor"))
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
