//
//  DailyCalorieView.swift
//  MeokPT
//
//  Created by vKv on 5/9/25.
//

import SwiftUI

struct DailyCalorieView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isManualInput: Bool = false
    
    @State private var calorieData: [(name: String, value: String, unit: String)] = [
        ("칼로리", "", "kcal"),
        ("탄수화물", "", "g"),
        ("단백질", "", "g"),
        ("지방", "", "g"),
        ("식이섬유", "", "g"),
        ("당류", "", "g"),
        ("나트륨", "", "mg")
    ]
    
    private let defaultCalorieData: [(name: String, value: String, unit: String)] = [
        ("칼로리", "", "kcal"),
        ("탄수화물", "", "g"),
        ("단백질", "", "g"),
        ("지방", "", "g"),
        ("식이섬유", "", "g"),
        ("당류", "", "g"),
        ("나트륨", "", "mg")
    ]
    
    @State private var showResetAlert = false
    @FocusState private var focusedFieldIndex: Int?
    
    let calorieDataKey = "DailyCalorieData"
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 36) {
                        HStack {
                            Text("수치 직접 입력")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Toggle("", isOn: $isManualInput)
                                .toggleStyle(SwitchToggleStyle(tint: Color("AppTintColor")))
                        }
                        .padding(.horizontal)
                        .padding(.top, 30)
                        
                        VStack(spacing: 0) {
                            ForEach(calorieData.indices, id: \.self) { index in
                                HStack {
                                    Text(calorieData[index].name)
                                        .foregroundColor(Color("AppTertiaryColor"))
                                    Spacer()
                                    
                                    if isManualInput {
                                        TextField("입력", text: $calorieData[index].value)
                                            .keyboardType(.decimalPad)
                                            .focused($focusedFieldIndex, equals: index)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 80)
                                        Text(calorieData[index].unit)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("\(calorieData[index].value)\(calorieData[index].unit)")
                                            .foregroundColor(.black)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                
                                if index != calorieData.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 120) // 버튼 공간 확보
                }
                .scrollDismissesKeyboard(.interactively)
            }
            
            VStack {
                Spacer()
                Button(action: {
                    saveCalorieData()
                    dismiss()
                }) {
                    Text("목표 섭취량 저장")
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
        .ignoresSafeArea(.keyboard) // 키보드가 떠도 레이아웃 유지
        .background(Color("AppBackgroundColor"))
        .navigationTitle("하루 목표 섭취량")
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
                    focusedFieldIndex = nil
                }
            }
        }
        .alert("입력값을 초기화할까요?", isPresented: $showResetAlert) {
            Button("초기화", role: .destructive) {
                calorieData = defaultCalorieData
                saveCalorieData()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("모든 입력값이 초기화됩니다.")
        }
        .onAppear {
            loadCalorieData()
        }
    }
    
    private func saveCalorieData() {
        let values = calorieData.map { $0.value }
        UserDefaults.standard.set(values, forKey: calorieDataKey)
    }
    
    private func loadCalorieData() {
        if let savedValues = UserDefaults.standard.array(forKey: calorieDataKey) as? [String], savedValues.count == calorieData.count {
            for i in 0..<savedValues.count {
                calorieData[i].value = savedValues[i]
            }
        }
    }
}

#Preview {
    DailyCalorieView()
}
