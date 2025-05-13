import ComposableArchitecture
import SwiftUI


struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        NavigationStack(path: $store.path) {
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
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(Color(UIColor.systemBackground), for: .tabBar)
            }
            .tint(.primary)
            // MARK: - fullScreenCover, sheet 또는 네비게이션 생성
            .fullScreenCover(
                item: Binding(
                    get: {
                        store.appRoute?.screenType == .fullScreenCover ? store.appRoute : nil
                    },
                    set: { newValue in
                        store.send(.setActiveSheet(newValue))
                    }
                )
            ) {_ in
                AppSheetContentView(store: store)
            }
            .sheet(
                item: Binding(
                    get: {
                        store.appRoute?.screenType == .sheet ? store.appRoute : nil
                    },
                    set: { newValue in
                        store.send(.setActiveSheet(newValue))
                    }
                )
            ) {_ in
                AppSheetContentView(store: store)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])  // 여기도 나중에 분기
            }
//            .navigationDestination(for: AppRoute.self) { route in
//                switch route {
//                case .dietDetailView:
//                    DietDetailView(store: store.scope(
//                        state: \.dietState,
//                        action: \.dietAction,
//                    ))
//                default:
//                    Text("지원하지 않는 화면입니다")
//                }
//            }
        }
    }
}

// MARK: - Sheet에 들어갈 내용을 분기하는 뷰
struct AppSheetContentView: View {
    let store: StoreOf<AppFeature>

    var body: some View {
        if let sheet = store.appRoute {
            NavigationStack {
                switch sheet {
                case .loginView:
                    LoginView(store: store.scope(
                        state: \.loginState,
                        action: \.loginAction
                    ))
                default:
                    EmptyView()
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
    .tint(.primary)
}
