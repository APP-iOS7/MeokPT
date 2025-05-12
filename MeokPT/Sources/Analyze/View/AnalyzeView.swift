import SwiftUI
import ComposableArchitecture
struct AnalyzeView: View {
    let store: StoreOf<AnalyzeFeature>
    
    @State private var isSheetPresented = false
    @State private var isAIModal = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color("AppBackgroundColor")
                               .ignoresSafeArea()
//                    ScrollView {
//                        VStack {
//                            // TODO: - 신체 정보, 식단의 유무에 따라 다른 뷰를 이용
//                        }
//                        .navigationTitle("분석")
//                        .navigationBarTitleDisplayMode(.inline)
//                        .background(Color("AppBackgroundColor"))
//                    }
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            withAnimation {
                                isAIModal = true
                            }
                        } label: {
                            Text("AI 식단 분석")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundStyle(.black)
                                .background(Color("AppTintColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 24)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                isSheetPresented = true
                            } label: {
                                Text("식단 추가")
                                    .foregroundStyle(Color("AppTintColor"))
                                    .fontWeight(.semibold)
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                            } label: {
                                Text("비우기")
                                    .foregroundStyle(Color("AppTintColor"))
                            }
                        }
                    }
                    .sheet(isPresented: $isSheetPresented) {
                        PickDietView()
                    }
                    .sheet(isPresented: $isAIModal) {
                        AIModalView(isPresented: $isAIModal)
                            .presentationDragIndicator(.visible)
                            .presentationDetents([.fraction(0.8), .fraction(0.5)])
                    }
                }
            }
            .scrollContentBackground(.hidden)

        }
        .animation(.easeInOut, value: isAIModal)
    }
}

#Preview {
    AnalyzeView(
        store: Store(initialState: AnalyzeFeature.State()) {
            AnalyzeFeature()
        }
    )
}


