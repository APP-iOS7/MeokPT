import ComposableArchitecture
import SwiftUI
import SwiftData

struct BodyInfoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @FocusState private var focusedField: Field?
    
    let store: StoreOf<BodyInfoInputFeature>
    let onSaveCompleted: (BodyInfoInputFeature.State) -> Void

    enum Field {
        case height, age, weight
    }
    

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Spacer()
            VStack(spacing: 20) {
                Group {
                    TextField("신장 (cm)", text: viewStore.binding(
                        get: \.height,
                        send: { .heightChanged($0) }
                    ))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .height)
                    
                    TextField("나이", text: viewStore.binding(
                        get: \.age,
                        send: { .ageChanged($0) }
                    ))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .age)
                    
                    TextField("체중 (kg)", text: viewStore.binding(
                        get: \.weight,
                        send: { .weightChanged($0) }
                    ))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .weight)
                }
                .padding(.bottom, 10)

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
                
                Spacer()
                
                HStack {
                    Text("식단 목표")
                        .font(.title3)
                        .foregroundStyle(Color("AppSecondaryColor"))
                    Spacer()
                    Picker("식단 목표 선택", selection: viewStore.binding(
                       get: \.selectedGoal,
                       send: { .goalChanged($0) }
                   )) {
                       ForEach(Goal.allCases) { goal in // id: \.self 불필요 (Identifiable)
                           Text(goal.rawValue).tag(goal)
                       }
                   }
                   .tint(Color("TextButton"))
                }
                
                Spacer()

                ActivityLevelScrollView(
                    selectedLevel: viewStore.binding(
                        get: \.selectedActivityLevel,
                        send: { .activityLevelChanged($0) }
                    ),
                    onSelect: { level in
                        viewStore.send(.activityLevelChanged(level))
                    }
                )

                Spacer()
                
                Button(action: {
                    viewStore.send(.saveButtonTapped(modelContext))
                    onSaveCompleted(viewStore.state)
                }) {
                    Text("완료")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("AppTintColor", bundle: nil))
                        .foregroundColor(.black)
                        .cornerRadius(28)
                }

            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .background(Color("AppBackgroundColor", bundle: nil).ignoresSafeArea())
            .ignoresSafeArea(.keyboard)
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

