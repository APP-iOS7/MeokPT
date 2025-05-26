import ComposableArchitecture
import SwiftUI

struct AIModalView: View {
    @Bindable var store: StoreOf<AISheetFeature>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI 식단 평가")
                .foregroundStyle(.black)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)

            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("AI가 분석 중입니다...")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

            } else {
                if let attributedString = try? AttributedString(markdown: store.generatedResponse) {
                    Text(attributedString)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.horizontal)
                } else {
                    Text(store.generatedResponse)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(8)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .onAppear {
            store.send(.onAppear)
        }
    }
}
