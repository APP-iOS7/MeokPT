import ComposableArchitecture
import SwiftUI

@Reducer
struct CommunityDetailFeature {
    @ObservableState
    struct State: Equatable{
        var communityPost: CommunityPost
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

