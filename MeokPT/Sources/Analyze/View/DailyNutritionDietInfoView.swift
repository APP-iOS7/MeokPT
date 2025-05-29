import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionDietInfoView: View {
    @Bindable var store: StoreOf<DailyNutritionDietInfoFeature>
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackgroundColor")
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        content(for: store)
                        
                        if store.isAIbuttonEnabled {
                            Button {
                                store.send(.presentAISheet)
                            } label: {
                                Text("AI 식단 분석")
                                    .font(.headline.bold())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .foregroundColor(.black)
                                    .buttonStyle(PlainButtonStyle())
                                    .background(Color("AppTintColor"))
                                    .cornerRadius(30)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 10)
                            }
                        } else {
                            EmptyView()
                        }
                        
                    }
                    .navigationTitle("분석")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color("AppBackgroundColor"))
                }
                .scrollContentBackground(.hidden)
//                .safeAreaInset(edge: .bottom) {
//                    if store.isAIbuttonEnabled {
//                        Button {
//                            store.send(.presentAISheet)
//                        } label: {
//                            Text("AI 식단 분석")
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .foregroundStyle(.black)
//                                .background(Color("AppTintColor"))
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                                .padding(.horizontal, 24)
//                                .padding(.bottom, 10)
//                        }
//                    } else {
//                        EmptyView()
//                    }
//                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            store.send(.presentDietSelectionSheet)
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
            item: $store.scope(state: \.dietSelectionSheet, action: \.dietSelectionSheetAction)
        ) { modalStore in
            NavigationStack {
                DietSelectionModalView(store: modalStore)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(
            item: $store.scope(state: \.aiSheet, action: \.aiSheetAction)
        ) { modalStore in
            NavigationStack {
                AIModalView(store: modalStore)
            }
            .presentationDragIndicator(.visible)
        }
        
        .onAppear {
            if store.nutritionItems == nil && !store.isLoading {
                print("DailyNutritionDietInfoView: Initial load on appear.")
                store.send(.loadInfo(context))
            }
            print("DailyNutritionDietInfoView: Sending .task action to start listener.")
            store.send(.task)
        }
//        .onChange(of: store.lastDataChangeTimestamp) { oldValue, newValue in
//            if oldValue != newValue {
//                print("Values are different. Sending .loadInfo(context)...")
//                store.send(.loadInfo(context))
//            } else {
//                print("Values were identical in onChange. Not sending .loadInfo.")
//            }
//        }
    }

    // TODO: - 신체정보가 있고 식단이 없는 경우
    @ViewBuilder
    private func content(for store: Store<DailyNutritionDietInfoFeature.State, DailyNutritionDietInfoFeature.Action>) -> some View {
        VStack {
            if store.isLoading {
                ProgressView("로딩 중입니다…")
                    .padding()
            } else if let nutritionItems = store.nutritionItems {
                if nutritionItems.isEmpty {
                    DailyNutritionInfoEmptyView(
                       onNavigateToMyPageButtonTap: {
//                           store.send(.myPageNavigationButtonTapped)
                       }
                   )
                } else {
                    DailyNutritionInfoView(nutritionItems: nutritionItems)
                    
                    if let dietItem = store.dietItems {
                        if dietItem.isEmpty {
                            DietEmptyView()
                        } else {
                            DietNotEmptyView()
                        }
                    } else {
                        DietEmptyView()
                    }
                }
            } else if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            } else {
                DailyNutritionInfoEmptyView(
                   onNavigateToMyPageButtonTap: {
//                       store.send(.myPageNavigationButtonTapped)
                   }
               )
            }
        }
    }
}

#Preview {
    DailyNutritionDietInfoView(store: Store(initialState: DailyNutritionDietInfoFeature.State()) {
        DailyNutritionDietInfoFeature()
    })
}
