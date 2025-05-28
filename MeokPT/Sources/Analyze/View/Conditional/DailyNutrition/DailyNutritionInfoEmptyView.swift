// DailyNutritionInfoEmptyView.swift

import SwiftUI

struct DailyNutritionInfoEmptyView: View {
    var onNavigateToMyPageButtonTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("하루 권장 영양분 섭취량이 없습니다")
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)

            Button {
                onNavigateToMyPageButtonTap()
            } label: {
                Text("하루 권장 영양분 설정")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color("AppTintColor"))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    DailyNutritionInfoEmptyView(onNavigateToMyPageButtonTap: {
        print("마이페이지 이동 버튼 탭됨 (프리뷰)")
    })
}
