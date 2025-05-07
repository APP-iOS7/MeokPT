import ComposableArchitecture
import SwiftUI


struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            Group {
                DietView(store: store.scope(state: \.dietState, action: \.dietAction))
                    .tabItem {
                        Text("식단")
                    }
                AnalyzeView(store: store.scope(state: \.analyzeState, action: \.analyzeAction))
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
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
    .tint(Color("AppTintColor"))
}
