import SwiftUI
import ComposableArchitecture

@main
struct MeokPTApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: MeokPTApp.store)
        }
    }
}
