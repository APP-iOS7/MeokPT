import SwiftUI
import ComposableArchitecture
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth


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
    
    init() {
        KakaoSDK.initSDK(appKey: "e45aac872cc22f70369464e409b9b04b")
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: MeokPTApp.store)
                .modelContainer(for: [BodyInfo.self, NutritionItem.self, DietItem.self, Diet.self, Food.self, SharedPostRecord.self, AnalyzeHistory.self])
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
