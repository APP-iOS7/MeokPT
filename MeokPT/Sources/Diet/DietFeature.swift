import ComposableArchitecture
import Foundation

@Reducer
struct DietFeature {
    // MARK: - State
    @ObservableState // SwiftUI 뷰에서 관찰 가능하도록 설정
    struct State: Equatable { // 테스트 용이성을 위해 Equatable 채택
        
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
    }
    
    enum CancelID { case timer }
    
    // MARK: - Reducer Body
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
