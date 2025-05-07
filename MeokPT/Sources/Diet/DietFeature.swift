import ComposableArchitecture
import Foundation

@Reducer
struct DietFeature {
    @ObservableState
    struct State {
        
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
