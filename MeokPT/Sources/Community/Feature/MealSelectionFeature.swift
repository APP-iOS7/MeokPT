//
//  MealSelectionFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/22/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MealSelectionFeature {
    
    @ObservableState
    struct State: Equatable, Hashable {
        var title: String = ""
        var content: String = ""
        var isFavoriteTab: Bool = false
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

