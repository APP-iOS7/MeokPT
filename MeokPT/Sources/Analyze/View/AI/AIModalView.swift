import ComposableArchitecture
import SwiftUI

struct AIModalView: View {
    @Bindable var store: StoreOf<AISheetFeature>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {            
            Text("AI 식단 평가")
                .foregroundStyle(.black)
                .font(.title3)

            if store.isLoading {
                ProgressView()
                Text("AI가 분석 중입니다...")
                    .font(.caption)
                    .foregroundStyle(.gray)
            } else {
                Text(store.generatedResponse)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            store.send(.onAppear)
        }
    }
}
