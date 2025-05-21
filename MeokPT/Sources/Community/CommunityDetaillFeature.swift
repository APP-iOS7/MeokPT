//
//  CommunityDetaillFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/21/25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct CommunityDetaillFeature {
    @ObservableState
    struct State {
        var postTitle: String
        var postBody: String
        var imageColor: Color
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

