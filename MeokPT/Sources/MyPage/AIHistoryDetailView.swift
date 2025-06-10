//
//  AIHistoryDetailView.swift
//  MeokPT
//
//  Created by 김동영 on 6/10/25.
//

import SwiftUI
import MarkdownUI

struct AIHistoryDetailView: View {
    let item: AnalyzeHistoryData
    let onDismiss: () -> Void
    
    @State private var selectedTab = 0
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter.string(from: item.timestamp)
    }
    
    private var parsedNutritionData: ParsedNutritionData? {
        guard let data = item.encodedData.data(using: .utf8) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            
            // 먼저 JSON이 유효한지 확인
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            print("JSON 구조 확인: \(jsonObject)")
            
            return try decoder.decode(ParsedNutritionData.self, from: data)
        } catch {
            print("JSON 파싱 오류: \(error)")
            
            // 에러가 발생한 경우 JSON 구조를 다시 확인해보기 위한 디버깅
            if let jsonString = String(data: data, encoding: .utf8) {
                print("원본 JSON 문자열: \(jsonString)")
            }
            
            // 다른 가능한 구조로 파싱 시도
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("JSON 키들: \(Array(jsonDict.keys))")
                }
            } catch {
                print("JSON 구조 분석 실패: \(error)")
            }
            
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 탭 선택기
                Picker("View Mode", selection: $selectedTab) {
                    Text("AI 분석").tag(0)
                    Text("식단 정보").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 날짜 정보
                HStack {
                    Label(formattedDate, systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                Divider()
                
                // 컨텐츠 영역
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if selectedTab == 0 {
                            // AI 분석 결과
                            Markdown(item.cleanedResponse)
                                .padding(.horizontal)
                        } else {
                            // 원본 데이터
                            if let nutritionData = parsedNutritionData {
                                VStack(alignment: .leading, spacing: 16) {
                                    // 식단 데이터 섹션
                                    if !nutritionData.actualMeals.isEmpty {
                                        // 식사 항목들
                                        ForEach(Array(nutritionData.actualMeals.enumerated()), id: \.element.id) { index, meal in
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    if meal.mealType != "해당없음" {
                                                        Text("\(meal.mealType.mealTypeDisplayName)")
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                MealItemRowView(meal: meal)
                                            }
                                        }
                                        .padding(24)
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                    
                                    // 권장 섭취량 섹션
                                    if !nutritionData.actualRecommendedIntake.isEmpty {
                                        VStack(alignment: .leading, spacing: 16) {
                                            Text("권장 섭취량")
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                            ForEach(nutritionData.actualRecommendedIntake, id: \.id) { item in
                                                HStack {
                                                    Text(item.nutrientName)
                                                        .font(.body).bold()
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                    Text("\(String(format: "%.0f", item.recommendedIntake)) \(item.unit)")
                                                        .font(.body)
                                                        .foregroundStyle(.primary)
                                                }
                                            }
                                        }
                                        .padding(24)
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(12)
                                        .padding(.horizontal)
                                    }
                                }
                            } else {
                                // JSON 파싱 실패 시 원본 텍스트 표시
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Label("원본 식단 데이터", systemImage: "doc.text")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        
                                        // 복사 버튼
                                        Button(action: {
                                            UIPasteboard.general.string = item.encodedData
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(item.encodedData)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("분석 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
