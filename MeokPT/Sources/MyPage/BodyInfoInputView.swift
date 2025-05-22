import ComposableArchitecture
import SwiftUI
import SwiftData

struct BodyInfoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    
    let store: StoreOf<BodyInfoInputFeature>
    let onSaveCompleted: (BodyInfoInputFeature.State) -> Void

    enum Field: Hashable {
        case height, age, weight
    }
    

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 40) {
                    
                    VStack(spacing: 30) {
                        TextField("신장 (cm)", text: viewStore.binding(
                            get: \.height,
                            send: { .heightChanged($0) }
                        ))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .height)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .weight
                        }
                        
                        TextField("체중 (kg)", text: viewStore.binding(
                            get: \.weight,
                            send: { .weightChanged($0) }
                        ))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .weight)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .age
                        }
                        
                        TextField("나이", text: viewStore.binding(
                            get: \.age,
                            send: { .ageChanged($0) }
                        ))
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .age)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                        }
                    }

                    VStack {
                        Picker("성별 선택", selection: viewStore.binding(
                            get: \.selectedGender,
                            send: { .genderChanged($0) }
                        )) {
                            ForEach(Gender.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    
                    HStack {
                        Text("식단 목표")
                            .font(.title3)
                            .foregroundStyle(Color("AppSecondaryColor"))
                        Spacer()
                        Picker("식단 목표 선택", selection: viewStore.binding(
                            get: \.selectedGoal,
                            send: { .goalChanged($0) }
                        )) {
                            ForEach(Goal.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .tint(Color("TextButton"))
                    }
                    

                    ActivityLevelScrollView(
                        selectedLevel: viewStore.binding(
                            get: \.selectedActivityLevel,
                            send: { .activityLevelChanged($0) }
                        ),
                        onSelect: { level in
                            viewStore.send(.activityLevelChanged(level))
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
            }
            .background(Color("AppBackgroundColor"))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: {
                    focusedField = nil
                    viewStore.send(.saveButtonTapped(modelContext))
                    onSaveCompleted(viewStore.state)
                }) {
                    Text("완료")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("AppTintColor", bundle: nil))
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(Color("AppBackgroundColor"))
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("완료") {
//                        focusedField = nil
//                    }
//                }
//            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}
