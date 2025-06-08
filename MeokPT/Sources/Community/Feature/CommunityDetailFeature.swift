import ComposableArchitecture
import SwiftUI

@Reducer
struct CommunityDetailFeature {
    @ObservableState
    struct State: Equatable{
        var communityPost: CommunityPost
        
        var formattedDate: String {
            let now = Date()
            let timeInterval = now.timeIntervalSince(communityPost.createdAt)
            
            let minutes = Int(timeInterval / 60)
            let hours = Int(timeInterval / 3600)
            let days = Int(timeInterval / 86400)
            
            if minutes < 1 {
                return "방금 전"
            } else if minutes < 60 {
                return "\(minutes)분 전"
            } else if hours < 24 {
                return "\(hours)시간 전"
            } else if days <= 3 {
                return "\(days)일 전"
            } else {
                let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M월 d일"
                    return formatter
                }()
                return dateFormatter.string(from: communityPost.createdAt)
            }
        }
        
        var kcal: Double {
            communityPost.foodList.compactMap { $0.kcal }.reduce(0.0, +)
        }
        var carbohydrate: Double {
            communityPost.foodList.compactMap { $0.carbohydrate }.reduce(0.0, +)
        }
        var protein: Double {
            communityPost.foodList.compactMap { $0.protein }.reduce(0.0, +)
        }
        var fat: Double {
            communityPost.foodList.compactMap { $0.fat }.reduce(0.0, +)
        }
        
        var showAlertToast: Bool = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case getShareButtonTapped
        
        case hideToast
    }
    
    enum CancelID { case timer }
    
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .getShareButtonTapped:
                // TODO: 식단 정보를 내 식단 리스트에 저장하는 로직, 로컬에 이 식단을 저장한 기록을 저장하고, 중복 방지
                
                state.showAlertToast = true
                return .run { send in
                    try await Task.sleep(for: .seconds(3))
                    await send(.hideToast)
                }
                
            case .hideToast:
                state.showAlertToast = false
                return .none
                
            case .binding(_):
                return .none
            }
        }
    }
}

