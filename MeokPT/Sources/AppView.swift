import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            Group {
                DietView(store: store.scope(state: \.dietState, action: \.dietAction))
                    .tabItem {
                        Text("식단")
                    }
                DailyNutritionDietInfoView(store: store.scope(state: \.analyzeState, action: \.analyzeAction))
                    .tabItem {
                        Text("분석")
                    }
                CommunityView(store: store.scope(state: \.communityState, action: \.communityAction))
                    .tabItem {
                        Text("커뮤니티")
                    }
                MyPageView(store: store.scope(state: \.myPageState, action: \.myPageAction))
                    .tabItem {
                        Text("마이페이지")
                    }
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
        }
        .tint(.primary)
        .onAppear {
            store.send(.onAppear)
        }
        .fullScreenCover(
            store: store.scope(state: \.$loginFullScreenCover, action: \.loginAction)
        ) { loginStore in
            NavigationStack {
                LoginView(store: loginStore)
            }
        }
        .fullScreenCover(
            store: store.scope(state: \.$profileSettingFullScreenCover, action: \.profileSettingAction)
        ) { profileStore in
            NavigationStack {
                ProfileSettingView(store: profileStore)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .tint(.primary)
}
