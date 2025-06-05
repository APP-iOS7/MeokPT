//
//  MealSelectionFeature.swift
//  MeokPT
//
//  Created by 김동영 on 5/22/25.
//

import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct MealSelectionFeature {
    
    @ObservableState
    struct State: Equatable, Hashable {
        var title: String = ""
        var content: String = ""
        var isFavoriteTab: Bool = false
        
        var dietList: IdentifiedArrayOf<Diet> = []
        var currentDietList: [Diet] {
            dietList.elements
        }
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case dietsLoaded([Diet])
    }
    
    enum CancelID { case timer }
    
    @Dependency(\.modelContainer) var modelContainer
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await MainActor.run {
                        do {
                            let context = modelContainer.mainContext
                            let descriptor = FetchDescriptor<Diet>(sortBy: [SortDescriptor(\.title)])
                            let diets = try context.fetch(descriptor)
                            send(.dietsLoaded(diets))
                        } catch {
                            print("Failed to fetch diets: \(error)")
                            send(.dietsLoaded([]))
                        }
                    }
                }
                
            case let .dietsLoaded(diets):
                state.dietList = IdentifiedArrayOf(uniqueElements: diets)
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

