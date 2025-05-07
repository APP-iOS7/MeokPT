import ComposableArchitecture

@Reducer
struct AppFeature {
    
    @ObservableState
    struct State: Equatable {
        var dietState = DietFeature.State()
        var analyzeState = AnalyzeFeature.State()
        var communityState = CommunityFeature.State()
        var myPageState = MyPageFeature.State()
    }
    
    enum Action {
        case dietAction(DietFeature.Action)
        case analyzeAction(AnalyzeFeature.Action)
        case communityAction(CommunityFeature.Action)
        case myPageAction(MyPageFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.dietState, action: \.dietAction) {
            DietFeature()
        }
        
        Scope(state: \.analyzeState, action: \.analyzeAction) {
            AnalyzeFeature()
        }
        
        Scope(state: \.communityState, action: \.communityAction) {
            CommunityFeature()
        }
        
        Scope(state: \.myPageState, action: \.myPageAction) {
            MyPageFeature()
        }
        
        Reduce { state, action in
            // Core logic of the app feature
            return .none
        }
    }
}
