import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct DietDetailFeature {
    @ObservableState
    struct State: Equatable {
        var diet: Diet
        let dietID: UUID
        
        @Presents var createDietFullScreenCover: CreateDietFeature.State?
        
        static func == (lhs: DietDetailFeature.State, rhs: DietDetailFeature.State) -> Bool {
            lhs.diet.id == rhs.diet.id &&
            lhs.dietID == rhs.dietID &&
            lhs.createDietFullScreenCover == rhs.createDietFullScreenCover
        }
    }
    
    enum Action {
        case likeButtonTapped
        case updateTitle(String)
        case addFoodButtonTapped
        case createDietFullScreenCover(PresentationAction<CreateDietFeature.Action>)
        case delegate(DelegateAction)
    }

    enum DelegateAction: Equatable {
        case favoriteToggled(isFavorite: Bool)
        case addFoodToDiet(foodName: String, amount: Double, calories: Double, carbohydrates: Double?, protein: Double?, fat: Double?, dietaryFiber: Double?, sugar: Double?, sodium: Double?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .likeButtonTapped:
                state.diet.isFavorite.toggle()
                return .send(.delegate(.favoriteToggled(isFavorite: state.diet.isFavorite)))
            case let .updateTitle(newTitle):
                state.diet.title = newTitle
                return .none
            case .addFoodButtonTapped:
                state.createDietFullScreenCover = CreateDietFeature.State()
                return .none
            case .createDietFullScreenCover(.presented(.delegate(.dismissSheet))):
                state.createDietFullScreenCover = nil
                return .none
            case .createDietFullScreenCover(.presented(.delegate(.addFoodToDiet(let foodName, let amount, let calories, let carbohydrates, let protein, let fat, let dietaryFiber, let sugar, let sodium)))):
                return .send(.delegate(.addFoodToDiet(
                    foodName: foodName,
                    amount: amount ?? 0,
                    calories: calories,
                    carbohydrates: carbohydrates,
                    protein: protein,
                    fat: fat,
                    dietaryFiber: dietaryFiber,
                    sugar: sugar,
                    sodium: sodium
                )))
            case .createDietFullScreenCover(_):
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$createDietFullScreenCover, action: \.createDietFullScreenCover) {
            CreateDietFeature()
        }
    }
}
