import SwiftUI

struct AIModalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {            
            Text("AI 식단 평가")
                .foregroundStyle(.black)
                .font(.title3)

            Text("하나의 식단 평가와 달리, 분석 탭에서 추가한 모든 식단을 고려하여 프롬프트 제작한다.")
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }
}
