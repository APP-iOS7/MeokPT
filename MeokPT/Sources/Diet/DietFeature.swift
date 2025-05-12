import ComposableArchitecture
import Foundation

// Diet 모델에 임시 sampleFoods 함수 추가 (실제 앱에서는 적절한 데이터 소스로 대체)
extension Diet {
    static func sampleFoods(for dietTitle: String) -> [Food] {
        if dietTitle.contains("닭가슴살 샐러드") {
            return [
                Food(name: "닭가슴살", amount: 100, kcal: 165, carbohydrate: 0, protein: 31, fat: 3.6),
                Food(name: "채소믹스", amount: 150, kcal: 35, carbohydrate: 7, protein: 2, fat: 0.5)
            ]
        } else if dietTitle.contains("현미밥과 연어구이") {
            return [
                Food(name: "현미밥", amount: 150, kcal: 165, carbohydrate: 36, protein: 3, fat: 1),
                Food(name: "연어구이", amount: 120, kcal: 250, carbohydrate: 0, protein: 24, fat: 16)
            ]
        } else if dietTitle.contains("두부김치") {
            return [
                Food(name: "두부", amount: 200, kcal: 160, carbohydrate: 4, protein: 16, fat: 9),
                Food(name: "볶음김치", amount: 150, kcal: 120, carbohydrate: 15, protein: 5, fat: 5)
            ]
        }
        return [
            Food(name: "샘플 음식", amount: 100, kcal: 100, carbohydrate: 10, protein: 10, fat: 2)
        ]
    }
}

@Reducer
struct DietFeature {
    @ObservableState
    struct State: Equatable {
        var dietList: IdentifiedArrayOf<Diet> = []
        var path = StackState<Path.State>() // 네비게이션 스택 상태 추가
    }
    
    enum Action {
        case onAppear
        case likeButtonTapped(id: Diet.ID)
        case path(StackAction<Path.State, Path.Action>) // 네비게이션 액션 추가
    }

    // 네비게이션 경로 정의
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case detail(DietDetailFeature.State)
        }
        enum Action {
            case detail(DietDetailFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.detail, action: \.detail) {
                DietDetailFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.dietList = [
                    Diet(title: "닭가슴살 샐러드", kcal: 350, carbohydrate: 20, protein: 40, fat: 10, isFavorite: false),
                    Diet(title: "현미밥과 연어구이", kcal: 550, carbohydrate: 60, protein: 35, fat: 18, isFavorite: true),
                    Diet(title: "두부김치", kcal: 400, carbohydrate: 30, protein: 25, fat: 20, isFavorite: false)
                ]
                return .none
                
            case let .likeButtonTapped(id):
                guard state.dietList[id: id] != nil else { return .none }
                state.dietList[id: id]?.isFavorite.toggle()
                return .none

            // Path 액션 처리
            case let .path(.element(id: pathID, action: .detail(.delegate(.favoriteToggled(isFavorite))))):
                // DietDetailView에서 즐겨찾기 상태가 변경되면 dietList 업데이트
                guard case let .detail(detailState) = state.path[id: pathID] else { return .none }
                if var dietToUpdate = state.dietList[id: detailState.diet.id] {
                    dietToUpdate.isFavorite = isFavorite
                    state.dietList[id: detailState.diet.id] = dietToUpdate
                }
                return .none
            
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) { // Path Reducer 통합
            Path()
        }
    }
}
