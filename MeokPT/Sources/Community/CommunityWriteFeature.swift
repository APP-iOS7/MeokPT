import ComposableArchitecture
import Foundation

@Reducer
struct CommunityWriteFeature {
    @ObservableState
    struct State {
        var title: String = ""
        var content: String = ""
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

