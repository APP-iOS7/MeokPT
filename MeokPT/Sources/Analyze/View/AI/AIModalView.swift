import SwiftUI
import ComposableArchitecture
import MarkdownUI

struct AIModalView: View {
    @Bindable var store: StoreOf<AISheetFeature>
    @Environment(\.dismiss) var dismiss

    private func stripMarkdownCodeBlockWrapper(from text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedText.hasPrefix("```") && trimmedText.hasSuffix("```") && trimmedText.count >= 6 {
            var innerContentSubstring = trimmedText.dropFirst(3).dropLast(3)
            if let firstNewlineIndex = innerContentSubstring.firstIndex(of: "\n") {
                let partBeforeNewline = innerContentSubstring[..<firstNewlineIndex]
            
                if partBeforeNewline.isEmpty || (!partBeforeNewline.isEmpty && partBeforeNewline.allSatisfy({ $0.isLetter || $0.isNumber })) {
                    innerContentSubstring = innerContentSubstring[innerContentSubstring.index(after: firstNewlineIndex)...]
                }
            }
            return String(innerContentSubstring)
        }
        return text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)

                Text("AI가 분석 중입니다...")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)

            } else {
                ScrollView {
                    let cleanedResponse = stripMarkdownCodeBlockWrapper(from: store.generatedResponse)
                    
                    if !cleanedResponse.isEmpty {
                        VStack(spacing: 24) {
                            Markdown(cleanedResponse)
                            
                            Button(action: {
                                store.send(.aiAnalyzeSave(cleanedResponse))
                                dismiss()
                            }) {
                                HStack {
                                    Text("분석 저장 후 닫기")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("AppTintColor"))
                                .cornerRadius(30)
                            }
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 24)
                    } else if !store.generatedResponse.isEmpty && cleanedResponse.isEmpty {
                        Text("분석 결과가 비어있습니다.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                         Text("분석 결과를 표시할 수 없습니다.")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AIModalView(store: Store(initialState: AISheetFeature.State(
        generatedResponse: "AI가 곧 분석 결과를 알려드립니다." 
    )) {
        AISheetFeature()
    })
}
