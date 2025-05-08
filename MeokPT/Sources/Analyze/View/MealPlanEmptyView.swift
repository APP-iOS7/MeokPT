import SwiftUI

struct MealPlanEmptyView: View {
    var body: some View {
        // MARK: - 식단이 없는 경우
        Text("추가한 식단이 없습니다")
            .foregroundStyle(Color.secondary)
        Spacer()
    }
}

#Preview {
    MealPlanEmptyView()
}
