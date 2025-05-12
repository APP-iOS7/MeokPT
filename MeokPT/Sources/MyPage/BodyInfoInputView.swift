//
//  BodyInfoInputView.swift
//  MeokPT
//
//  Created by vKv on 5/9/25.
//

import SwiftUI

struct BodyInfoInputView: View {
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var selectedGender: String = "여성"
    @State private var selectedGoal: String = "체중감량"
    
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    let userDefaultsKey = "BodyInfo"
    
    let genderOptions = ["여성", "남성"]
    let goalOptions = ["체중감량", "근육량 증가", "기타"]
    
    enum Field {
        case height, age, weight
    }
    
    @State private var showResetAlert = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 18)
                    
                    Text("정보 입력")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Group {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                TextField("키", text: $height)
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
                                TextField("나이", text: $age)
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
                                TextField("몸무게", text: $weight)
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
                                selectedGender = gender
                            }) {
                                Text(gender)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(selectedGender == gender ? Color.white : Color(UIColor.systemGray4))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("목표 설정")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("AppTintColor"))
                        
                        HStack(spacing: 8) {
                            ForEach(goalOptions, id: \.self) { goal in
                                Button(action: {
                                    selectedGoal = goal
                                }) {
                                    Text(goal)
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selectedGoal == goal ? Color("AppTintColor") : Color.gray.opacity(0.4))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    Spacer().frame(height: 120) // 버튼 공간 확보
                }
                .padding()
            }
            
            VStack {
                Spacer()
                Button(action: {
                    let info: [String: String] = [
                        "height": height,
                        "age": age,
                        "weight": weight,
                        "gender": selectedGender,
                        "goal": selectedGoal
                    ]
                    UserDefaults.standard.set(info, forKey: userDefaultsKey)
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
                height = ""
                age = ""
                weight = ""
                selectedGender = "여성"
                selectedGoal = "체중감량"
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("모든 입력값이 초기화됩니다.")
        }
        .onAppear {
            if let saved = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] {
                height = saved["height"] ?? ""
                age = saved["age"] ?? ""
                weight = saved["weight"] ?? ""
                selectedGender = saved["gender"] ?? "여성"
                selectedGoal = saved["goal"] ?? "체중감량"
            }
        }
    }
}

#Preview {
    BodyInfoInputView()
}
