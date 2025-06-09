import ComposableArchitecture
import SwiftUI
import SwiftData
import AlertToast

struct BodyInfoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    
    let onSaveCompleted: (BodyInfoInputFeature.State) -> Void
    @Bindable var store: StoreOf<BodyInfoInputFeature>

    enum Field: Hashable {
        case height, age, weight
    }
    
    var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    VStack(spacing: 30) {
                        VStack {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                TextField("신장 (cm)", text: $store.height.sending(\.heightChanged))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .height)
                                Text("cm")
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(UIColor.separator))
                        }
                        
                        VStack {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                TextField("체중 (kg)", text: $store.weight.sending(\.weightChanged))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .weight)
                                Text("kg")
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(UIColor.separator))
                        }
                        
                        VStack {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                TextField("나이", text: $store.age.sending(\.ageChanged))
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .age)
                                Text("세")
                            }
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(UIColor.separator))
                        }
                    }

                    VStack {
                        Picker("성별 선택", selection: $store.selectedGender.sending(\.genderChanged)) {
                            ForEach(Gender.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    
                    HStack {
                        Text("식단 목표")
                            .font(.title3)
                            .foregroundStyle(Color("App title"))
                        Spacer()
                        Picker("식단 목표 선택", selection: $store.selectedGoal.sending(\.goalChanged)) {
                            ForEach(Goal.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .tint(Color("TextButton"))
                    }
                    

                    ActivityLevelScrollView(
                        selectedLevel: $store.selectedActivityLevel.sending(\.activityLevelChanged),
                        onSelect: { level in
                            store.send(.activityLevelChanged(level))
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        focusedField = nil
                    }
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color("AppBackgroundColor"))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button(action: {
                    focusedField = nil
                    store.send(.saveButtonTapped)
                    onSaveCompleted(store.state)
                }) {
                    Text("저장")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color("AppTintColor"))
                        .cornerRadius(30)
                }
                .font(.headline.bold())
                .foregroundColor(.black)
                .buttonStyle(PlainButtonStyle())
                .contentShape(Rectangle())
                .padding(.horizontal, 24)
//                .alert("신체정보가 저장되었습니다.", isPresented: $showAlert) {
//                    Button("확인", role: .cancel) {}
//                } message: {
//                    Text("하루 권장 섭취량을 업데이트 합니다.")
//                }
            }
            .toast(isPresenting: Binding(
                get: { store.showAlertToast },
                set: { _ in }
            )) {
                AlertToast(
                    displayMode: .banner(.pop),
                    type: .complete(Color("AppSecondaryColor")),
                    title: "신체정보가 저장되었습니다.",
                    subTitle: "하루 권장 섭취량을 업데이트 합니다."
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
    }
}
