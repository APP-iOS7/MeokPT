import ComposableArchitecture

struct AISheetFeature: Reducer {
    struct State: Equatable {
    }

    enum Action: Equatable {
        case onAppear
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}

