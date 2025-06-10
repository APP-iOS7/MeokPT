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

        var selectedFilter: DietFilter = .all

        var dietList: IdentifiedArrayOf<Diet> = []
        var currentDietList: [Diet] {
            switch selectedFilter {
            case .all:
                return dietList.elements
            case .favorites:
                return dietList.elements.filter { $0.isFavorite }
            }
        }
    }
    
    enum Action: BindableAction {
        case delegate(DelegateAction)
        case binding(BindingAction<State>)
        case onAppear
        case dietsLoaded([Diet])
        case dietCellTapped(id: UUID)
        case dismissButtonTapped
    }
    
    enum DelegateAction: Equatable {
        case dismissSheet
        case selectDiet(diet: Diet)
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
                
            case let .dietCellTapped(id):
                if let diet = state.dietList[id: id] {
                    return .send(.delegate(.selectDiet(diet: diet)))
                }
                return .none
                
            case .dismissButtonTapped:
                return .send(.delegate(.dismissSheet))
                
            case .binding(_):
                return .none
            case .delegate(_):
                return .none

            }
        }
    }
}

