import ComposableArchitecture
import Foundation

@Reducer
struct CommunityPath {
    @ObservableState
    enum State: Equatable {
        case addPost(CommunityWriteFeature.State)
    }

    enum Action {
        case addPost(CommunityWriteFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.addPost, action: \.addPost) {
            CommunityWriteFeature()
        }
    }
}

@Reducer
struct CommunityFeature {
    @ObservableState
    struct State: Equatable{
        var searchText: String = ""
        
        var path = StackState<CommunityPath.State>()
    }
    
    enum Action: BindableAction{
        case binding(BindingAction<State>)
        case onAppear
        
        case path(StackAction<CommunityPath.State, CommunityPath.Action>) // 스택 변경 및 요소 액션 처리
        case navigateToAddButtonTapped
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case .navigateToAddButtonTapped:
                state.path.append(.addPost(CommunityWriteFeature.State()))
                return .none
                
            case .binding(_):
                return .none
            case .path(_):
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            CommunityPath()
        }
    }
}

