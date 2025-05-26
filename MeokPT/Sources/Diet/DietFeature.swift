import ComposableArchitecture
import Foundation

enum DietFilter: String, CaseIterable, Identifiable {
    case all = "전체"
    case favorites = "즐겨찾기"
    var id: String { self.rawValue }
}

@Reducer
struct DietFeature {
    @ObservableState
    struct State: Equatable {
        
        @Presents var createDietFullScreenCover: CreateDietFeature.State?
        
        var dietList: IdentifiedArrayOf<Diet> = []
        var searchText = ""
        var selectedFilter: DietFilter = .all
        
        var filteredDiets: [Diet] {
            let searchedDiets = searchText.isEmpty ? dietList.elements : dietList.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            switch selectedFilter {
            case .all:
                return Array(searchedDiets)
            case .favorites:
                return Array(searchedDiets.filter { $0.isFavorite })
            }
        }
    }
    
    enum Action: BindableAction {
        
        case createDietFullScreenCover(PresentationAction<CreateDietFeature.Action>)
        
        case binding(BindingAction<State>)
        case addButtonTapped
        case dietCellTapped(id: Diet.ID)
        case likeButtonTapped(id: Diet.ID, isFavorite: Bool)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.createDietFullScreenCover = CreateDietFeature.State()
                
                let newDiet = Diet(title: "새로운 식단", isFavorite: false, foods: [])
                state.dietList.append(newDiet)
                return .none
                
            case .dietCellTapped/*(let id)*/:
//                guard let diet = state.dietList[id: id] else { return .none }
                return .none
                
            case let .likeButtonTapped(id, isFavorite):
                guard var dietToUpdate = state.dietList[id: id] else {
                    return .none
                }
                if dietToUpdate.isFavorite != isFavorite {
                    _ = dietToUpdate.isFavorite
                    dietToUpdate.isFavorite = isFavorite
                    state.dietList[id: id] = dietToUpdate
                }
                return .none
                
            case .binding(_):
                return .none
                
            case .createDietFullScreenCover(.presented(.delegate(.dismissSheet))):
                state.createDietFullScreenCover = nil
                return .none
                
            case .createDietFullScreenCover(_):
                return .none
                
            }
        }
        .ifLet(\.$createDietFullScreenCover, action: \.createDietFullScreenCover) { CreateDietFeature() }
    }
}
