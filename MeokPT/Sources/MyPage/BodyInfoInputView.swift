import ComposableArchitecture
import SwiftUI
import SwiftData

struct BodyInfoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    
    let store: StoreOf<BodyInfoInputFeature>
    
    enum Field {
        case height, age, weight
    }
    
    @State private var showResetAlert = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                VStack(alignment: .leading, spacing: 24) {
                    
                    TextField("신장 (cm)", text: viewStore.binding(get: \.height, send:
                        BodyInfoInputFeature.Action.heightChanged))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .height)
                    
                    TextField("나이", text: viewStore.binding(get: \.age, send:
                        BodyInfoInputFeature.Action.ageChanged))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .age)
                    
                    TextField("체중 (kg)", text: viewStore.binding(get: \.weight, send:
                        BodyInfoInputFeature.Action.weightChanged))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .weight)
                
                    
                    Picker("성별 선택", selection: viewStore.binding(get: \.selectedGender, send:
                        BodyInfoInputFeature.Action.genderChanged)) {
                        ForEach(Gender.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .frame(width: 194, height: 25)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    Spacer().frame(height: 120)
                }
                .padding()
                
                VStack {
                    Spacer()
                    Button(action: {
                        viewStore.send(.saveButtonTapped(modelContext))
                        dismiss()
                    }) {
                        Text("완료")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("AppTintColor"))
                            .foregroundColor(.black)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(.keyboard)
            .background(Color("AppBackgroundColor").ignoresSafeArea())
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("저장") {
                        focusedField = nil
                    }
                }
            }
//            .alert("입력값을 초기화할까요?", isPresented: $showResetAlert) {
//                Button("초기화", role: .destructive) {
//                    viewStore.send(.heightChanged(""))
//                    viewStore.send(.ageChanged(""))
//                    viewStore.send(.weightChanged(""))
//                    viewStore.send(.genderChanged(.female))
//                    viewStore.send(.goalChanged(.loseWeight))
//                }
//                Button("취소", role: .cancel) { }
//            } message: {
//                Text("모든 입력값이 초기화됩니다.")
//            }
            .onAppear {
                viewStore.send(.loadSavedData(modelContext))
            }
        }
    }
}

#Preview {
    BodyInfoInputView(
        store: Store<BodyInfoInputFeature.State, BodyInfoInputFeature.Action>(
            initialState: BodyInfoInputFeature.State(),
            reducer: {
                BodyInfoInputFeature()
            }
        )
    )
}
