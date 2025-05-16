import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    let store: StoreOf<DailyNutritionFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 36) {
                            HStack {
                                Text("수치 직접 입력")
                                    .font(.headline)
                                Spacer()
                                Toggle("", isOn: viewStore.binding(get: \.isEditable, send: DailyNutritionFeature.Action.toggleChanged))
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            .padding(.top, 30)
                            
                            VStack(spacing: 0) {
                                ForEach(viewStore.rows) { item in
                                    NutritionRowView (
                                        name: item.name,
                                        value: item.value,
                                        unit: item.unit,
                                        isEditable: viewStore.isEditable 
                                    ) { newValue in
                                        viewStore.send(.valueChanged(type: item.type, text: newValue))
                                    }
                                    if item != viewStore.rows.last {
                                        Divider().padding(.horizontal)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 120)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
                
                VStack {
                    Spacer()
                    Button("목표 섭취량 저장") {
                        viewStore.send(.saveButtonTapped(context))
                        dismiss()
                    }
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("AppTintColor"))
                    .foregroundColor(.black)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(.keyboard)
            .background(Color("AppBackgroundColor"))
            .navigationTitle("하루 목표 섭취량")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewStore.send(.loadSavedData(context))
            }
        }
    }
}

#Preview {
    DailyNutritionView(
        store: Store(
            initialState: DailyNutritionFeature.State(
            ),
            reducer: {
                DailyNutritionFeature()
            }
        )
    )
}

