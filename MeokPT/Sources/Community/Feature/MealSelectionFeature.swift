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
        
        var dietList: IdentifiedArrayOf<Diet> = []
        var selectedFilter: DietFilter = .dateDescending
        var isFavoriteFilterActive: Bool = false
        var searchText: String = ""
        
        var currentDietList: [Diet] {
            let searchedDiets = searchText.isEmpty ? dietList.elements : dietList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            let favoriteFilteredDiets = isFavoriteFilterActive ? searchedDiets.filter { $0.isFavorite } : searchedDiets
            
            switch selectedFilter {
            case .dateDescending:
                return favoriteFilteredDiets.sorted { $0.creationDate > $1.creationDate }
            case .nameAscending:
                return favoriteFilteredDiets.sorted { $0.title.compare($1.title) == .orderedAscending }
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
        case favoriteFilterButtonTapped
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
                
            case .favoriteFilterButtonTapped:
                state.isFavoriteFilterActive.toggle()
                return .none
                
            case .binding(_):
                return .none
            case .delegate(_):
                return .none

            }
        }
    }
}

