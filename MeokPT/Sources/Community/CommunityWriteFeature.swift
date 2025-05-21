//
//  CommunityWriteFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/21/25.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CommunityWriteFeature {
    @ObservableState
    struct State {
        var title: String = ""
        var content: String = ""
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

