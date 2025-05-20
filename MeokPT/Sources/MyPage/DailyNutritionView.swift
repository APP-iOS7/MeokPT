import SwiftUI
import ComposableArchitecture
import SwiftData

struct DailyNutritionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    let store: StoreOf<DailyNutritionFeature>
    var onSaveTapped: (_ store: StoreOf<DailyNutritionFeature>, _ modelContext: ModelContext) -> Void

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(spacing: 20) {
                    HStack {
                        Text("수치 직접 입력")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: viewStore.binding(
                            get: \.isEditable,
                            send: DailyNutritionFeature.Action.toggleChanged
                        ))
                        .labelsHidden()
                        .tint(Color("AppTintColor"))
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    VStack(spacing: 0) {
                        ForEach(viewStore.rows) { item in
                            NutritionRowView(
                                name: item.name,
                                value: item.value,
                                unit: item.unit,
                                isEditable: viewStore.isEditable
                            ) { newValue in
                                viewStore.send(.valueChanged(type: item.type, text: newValue))
                            }
                            .padding(.vertical, 10)
                            
                            if item != viewStore.rows.last {
                                Divider().padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    

                    Spacer()
                    
                }

                .padding(.bottom, 90)

                VStack {
                    Spacer()
                    Button("완료") {
                        onSaveTapped(store, context)
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
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.keyboard)
            .background(Color("AppBackgroundColor"))
            .onAppear {
                viewStore.send(.loadSavedData(context))
            }
        }
    }
}
