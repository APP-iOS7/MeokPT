import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionDietInfoView: View {
    @Bindable var store: StoreOf<DailyNutritionDietInfoFeature>
    @Environment(\.modelContext) private var context

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                NavigationStack {
                    ZStack {
                        Color("AppBackgroundColor")
                            .ignoresSafeArea()
                        ScrollView {
                            VStack {
                                content(for: viewStore)
                            }
                            .navigationTitle("분석")
                            .navigationBarTitleDisplayMode(.inline)
                            .background(Color("AppBackgroundColor"))
                        }
                        .scrollContentBackground(.hidden) // If targeting iOS 16+ for ScrollView background
                        .safeAreaInset(edge: .bottom) {
                            Button {
                                viewStore.send(.presentAISheet)
                            } label: {
                                Text("AI 식단 분석")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundStyle(.black)
                                    .background(Color("AppTintColor"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 10)
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button {
                                    viewStore.send(.presentDietSelectionSheet) // Use viewStore
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
                .sheet(
                    store: self.store.scope(state: \.$dietSelectionSheet, action: \.dietSelectionSheetAction)
                ) { modalStore in
                    NavigationStack {
                        DietSelectionModalView(store: modalStore)
                    }
                    .presentationDragIndicator(.visible)
                }
                .sheet(
                    store: self.store.scope(state: \.$aiSheet, action: \.aiSheetAction)
                ) { modalStore in
                    NavigationStack {
                        AIModalView(store: modalStore)
                    }
                    .presentationDragIndicator(.visible)
                }
            }
            .onAppear {
                if viewStore.state.nutritionItems == nil && !viewStore.state.isLoading {
                    print("DailyNutritionDietInfoView: Initial load on appear.")
                    viewStore.send(.loadInfo(context))
                }
                print("DailyNutritionDietInfoView: Sending .task action to start listener.")
                viewStore.send(.task)
            }
            .onChange(of: viewStore.state.lastDataChangeTimestamp) { oldValue, newValue in
               if oldValue != newValue {
                   print("Values are different. Sending .loadInfo(context)...")
                   viewStore.send(.loadInfo(context))
               } else {
                   print("Values were identical in onChange. Not sending .loadInfo.")
               }
            }
        }
    }

    @ViewBuilder
    private func content(for viewStore: ViewStore<DailyNutritionDietInfoFeature.State, DailyNutritionDietInfoFeature.Action>) -> some View {
        if viewStore.isLoading {
            ProgressView("로딩 중입니다…")
                .padding()
        } else if let nutritionItems = viewStore.nutritionItems {
            if nutritionItems.isEmpty {
                DailyNutritionInfoEmptyView()
            } else {
                DailyNutritionInfoView(nutritionItems: nutritionItems)
            }
        } else if let errorMessage = viewStore.errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .padding()
        } else {
            DailyNutritionInfoEmptyView()
        }
    }
}

#Preview {
    DailyNutritionDietInfoView(store: Store(initialState: DailyNutritionDietInfoFeature.State()) {
        DailyNutritionDietInfoFeature()
    })
}
