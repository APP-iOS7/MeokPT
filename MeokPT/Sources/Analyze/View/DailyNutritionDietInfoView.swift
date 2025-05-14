import SwiftUI
import ComposableArchitecture

struct DailyNutritionDietInfoView: View {
    @Bindable var store: StoreOf<DailyNutritionDietInfoFeature>

    @State private var isSheetPresented = false
    @State private var isAIModal = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color("AppBackgroundColor")
                               .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            WithViewStore(self.store, observe: { $0 }) { viewStore in
                                content(for: viewStore)
                                    .onAppear {
                                        viewStore.send(.onAppear)
                                    }
                                
                            }
                        }
                        .navigationTitle("분석")
                        .navigationBarTitleDisplayMode(.inline)
                        .background(Color("AppBackgroundColor"))
                    }
                    .safeAreaInset(edge: .bottom) {
                        Button {
                            store.send(.toAIModalViewAction)
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
                                store.send(.toDietSelectionModalViewAction)
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
                }
            }
            .scrollContentBackground(.hidden)

        }
        .task {
            ViewStore(store, observe: { $0 }).send(.onAppear)
        }
        .animation(.easeInOut, value: isAIModal)
    }
    
    @ViewBuilder
    private func content(for viewStore: ViewStore<DailyNutritionDietInfoFeature.State, DailyNutritionDietInfoFeature.Action>) -> some View {
        if viewStore.isLoading {
            ProgressView("로딩 중입니다…")
        } else if viewStore.nutritionItems != nil {
            DailyNutritionInfoView(nutritionItems: mockNutritionItems)
        } else if let errorMessage = viewStore.errorMessage {
            Text(errorMessage)
                .font(.caption)
        } else {
            DailyNutritionInfoEmptyView()
        }
    }
}

//#Preview {
//    DailyNutritionDietInfoView(store: DailyNutritionDietInfoFeature)
//}

