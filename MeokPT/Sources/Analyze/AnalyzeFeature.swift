import ComposableArchitecture
import Foundation

@Reducer
struct AnalyzeFeature {
    @ObservableState
    struct State {
        // 비우기 툴바를 위한 변수
        // 식단 추가를 위한 변수
    }
    
    enum Action {
        case onAppear
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
