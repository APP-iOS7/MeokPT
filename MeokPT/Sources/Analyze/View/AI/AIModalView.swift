import SwiftUI
import ComposableArchitecture

struct AIModalView: View {
    @Bindable var store: StoreOf<AISheetFeature>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI 식단 평가")
                .foregroundStyle(.black)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)

            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("AI가 분석 중입니다...")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

            } else {
                ScrollView {
                    AttributedTextView(markdown: store.generatedResponse)
                        .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    AIModalView(store: Store(initialState: AISheetFeature.State()) {
        AISheetFeature()
    })
}
