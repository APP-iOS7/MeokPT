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
    
    let genderOptions = ["여성", "남성"]
    let goalOptions = ["체중감량", "근육량 증가", "기타"]
    let activityLevelOptions = ["매우 적음", "적음", "보통", "많음", "매우 많음"]
    
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Spacer().frame(height: 18)
                        
                        Group {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    TextField("키", text: viewStore.binding(get: \.height, send: BodyInfoInputFeature.Action.heightChanged))
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .height)
                                    Text("cm")
                                        .foregroundColor(.gray)
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    TextField("나이", text: viewStore.binding(get: \.age, send: BodyInfoInputFeature.Action.ageChanged))
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .age)
                                    Text("세")
                                        .foregroundColor(.gray)
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    TextField("몸무게", text: viewStore.binding(get: \.weight, send: BodyInfoInputFeature.Action.weightChanged))
                                        .keyboardType(.decimalPad)
                                        .focused($focusedField, equals: .weight)
                                    Text("kg")
                                        .foregroundColor(.gray)
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(genderOptions, id: \.self) { gender in
                                Button(action: {
                                    viewStore.send(.genderChanged(gender))
                                }) {
                                    Text(gender)
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(viewStore.selectedGender == gender ? Color.white : Color(UIColor.systemGray4))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        HStack {
                            Text("식단 목표")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color("AppTertiaryColor"))
                            Spacer()
                            Picker("목표", selection: viewStore.binding(get: \.selectedGoal, send: BodyInfoInputFeature.Action.goalChanged)) {
                                ForEach(goalOptions, id: \.self) { goal in
                                    Text(goal).tag(goal)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(Color("AppTintColor"))
                            .font(.system(size:24))
                        }
                        
                        HStack {
                            Text("평소 운동량")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(Color("AppTertiaryColor"))
                            Spacer()
                            Picker("운동량", selection: viewStore.binding(get: \.selectedActivityLevel, send: BodyInfoInputFeature.Action.activityLevelChanged)) {
                                ForEach(activityLevelOptions, id: \.self) { level in
                                    Text(level).tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(Color("AppTintColor"))
                            .font(.system(size: 24))
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ActivityLevelCard(title: "매우 적음", description: "주로 앉아서 보내며,\n신체적 활동이 거의 없는 일상.\n예: 사무직, TV 시청이 많음.")
                                ActivityLevelCard(title: "적음", description: "가벼운 운동이나 일상적인 활동.\n예: 가벼운 산책, 주 1~2회 운동.")
                                ActivityLevelCard(title: "보통", description: "주 3~5회 운동.")
                                ActivityLevelCard(title: "많음", description: "매일 운동. 주 6~7회.")
                                ActivityLevelCard(title: "매우 많음", description: "격렬한 운동 및 육체노동 직업.")
                            }
                            .padding(.vertical, 4)
                        }
                        
                        
                        
                        Spacer().frame(height: 120) // 버튼 공간 확보
                    }
                    .padding()
                }
                
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
            .navigationTitle("신체정보 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("재설정") {
                        showResetAlert = true
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        focusedField = nil
                    }
                }
            }
            .alert("입력값을 초기화할까요?", isPresented: $showResetAlert) {
                Button("초기화", role: .destructive) {
                    viewStore.send(.heightChanged(""))
                    viewStore.send(.ageChanged(""))
                    viewStore.send(.weightChanged(""))
                    viewStore.send(.genderChanged("여성"))
                    viewStore.send(.goalChanged("체중감량"))
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("모든 입력값이 초기화됩니다.")
            }
            .onAppear {
                viewStore.send(.loadSavedData(modelContext))
            }
        }
    }
}

struct ActivityLevelCard: View {
    var title: String
    var description: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.headline)
                .bold()
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(width: 200, height: 100, alignment: .center)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1))
//        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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

