import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.setSelectedTab)) {
            Group {
                DietView(store: store.scope(state: \.dietState, action: \.dietAction))
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("식단")
                    }
                    .tag(AppFeature.State.Tab.diet)
                DailyNutritionDietInfoView(store: store.scope(state: \.analyzeState, action: \.analyzeAction))
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("분석")
                    }
                    .tag(AppFeature.State.Tab.analyze)
                CommunityView(store: store.scope(state: \.communityState, action: \.communityAction))
                    .tabItem {
                        Image(systemName: "text.bubble")
                        Text("커뮤니티")
                    }
                    .tag(AppFeature.State.Tab.community)
                MyPageView(store: store.scope(state: \.myPageState, action: \.myPageAction))
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("마이페이지")
                    }
                    .tag(AppFeature.State.Tab.myPage)
            }
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
        }
        .tint(.primary)
        .onAppear {
            // "XCODE_RUNNING_FOR_PREVIEWS" 환경 변수가 "1"이면 프리뷰 환경입니다.
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                store.send(.onAppear) // 프리뷰가 아닐 때만 onAppear 액션 전송
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.loginFullScreenCover, action: \.loginAction)) { loginStore in
            NavigationStack {
                LoginView(store: loginStore)
                    .tint(Color("TextButton"))
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.profileSettingFullScreenCover, action: \.profileSettingAction)) { profileStore in
            NavigationStack {
                ProfileSettingView(store: profileStore)
                    .tint(Color("TextButton"))
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
