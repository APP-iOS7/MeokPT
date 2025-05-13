import SwiftUI
import ComposableArchitecture
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MeokPTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: MeokPTApp.store)
                .tint(Color("AppTintColor"))
        }
    }
}
