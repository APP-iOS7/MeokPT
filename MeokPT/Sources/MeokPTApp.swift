import SwiftUI
import ComposableArchitecture
import FirebaseCore

@main
struct MeokPTApp: App {
    init() {
      FirebaseApp.configure()
    }
    
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: MeokPTApp.store)
                .tint(Color("AppTintColor"))
                .modelContainer(for: [BodyInfo.self, NutritionItem.self])
        }
    }
}
