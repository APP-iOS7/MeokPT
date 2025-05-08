import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    let store: StoreOf<AnalyzeFeature>
    
    // 테스트용 데이터
    var nutritionInfo: [(key: String, value: Int)] = [
        ("열량", 2100),
        ("탄수화물", 20),
        ("단백질", 10),
        ("지방", 5),
        ("식이섬유", 3),
        ("당류", 8),
        ("나트륨", 200)
    ]
    
    let units: [String] = ["kcal", "g", "g", "g", "g", "g", "mg"]

    let maxNutritionInfo: [Int] = [2000, 100, 56, 35, 28, 20, 2000]
    
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // MARK: - 신체 정보가 없는 경우
                    //                Text("신체 정보가 없습니다")
                    //                    .font(.headline)
                    //                    .foregroundStyle(Color.secondary)
                    //                
                    // MARK: - 신체 정보가 있는 경우
                    VStack {
                        ForEach(Array(nutritionInfo.enumerated()), id: \.0) { index, item in
                            let unit = units[index]
                            let maxNutrition = maxNutritionInfo[index]
                            
                            VStack {
                                HStack {
                                    Text("\(item.key)")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(item.value)\(unit) / \(maxNutrition)\(unit)")
                                        .font(.caption)
                                }
                                ConditionalProgressView(current: Double(item.value), max: Double(maxNutrition))
                            }
                            .padding(10)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(Color.white)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    // MARK: - 식단이 없는 경우
                    //                Text("추가한 식단이 없습니다")
                    //                    .foregroundStyle(Color.secondary)
                    //                Spacer()
                    
                    // MARK: - 식단이 있는 경우
                    VStack(alignment: .leading, spacing: 16) {
                        // 헤더 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            Text("샐러드와 고구마")
                                .font(.headline)
                            Text("400kcal")
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 20) {
                            NutrientView(name: "탄수화물", value: "107.5g")
                            Spacer()
                            NutrientView(name: "단백질", value: "33.3g")
                            Spacer()
                            NutrientView(name: "지방", value: "8.2g")
                        }
                        .frame(width: .infinity)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(Color.white)
                    )
                    .padding(.horizontal, 24)
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // 헤더 섹션
                        VStack(alignment: .leading, spacing: 8) {
                            Text("샐러드와 고구마")
                                .font(.headline)
                            Text("400kcal")
                                .font(.subheadline)
                        }
                        
                        HStack(spacing: 20) {
                            NutrientView(name: "탄수화물", value: "107.5g")
                            Spacer()
                            NutrientView(name: "단백질", value: "33.3g")
                            Spacer()
                            NutrientView(name: "지방", value: "8.2g")
                        }
                        .frame(width: .infinity)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray, lineWidth: 1)
                            .background(Color.white)
                    )
                    .padding(.horizontal, 24)
                }
                .navigationTitle("분석")
                .navigationBarTitleDisplayMode(.inline)
                .containerRelativeFrame([.horizontal, .vertical])
                .background(Color("AppBackgroundColor"))
                // MARK: - AI 식단 분석 버튼
                
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    
                } label: {
                    Text("AI 식단 분석")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.black)
                        .background(Color("AppTintColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        
                    } label: {
                        Text("식단 추가")
                            .foregroundStyle(Color("AppTintColor"))
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        
                    } label: {
                        Text("비우기")
                            .foregroundStyle(Color("AppTintColor"))
                    }
                }
            }
        }
    }
}

struct ConditionalProgressView: View {
    var current: Double
    var max: Double
    
    var progressColor: Color {
        current > max ? .red : Color("Green")
    }
    
    var progressValue: Double {
        min(current, max)
    }
    
    var body: some View {
        ProgressView(value: progressValue, total: max)
            .tint(progressColor)
    }
}

struct NutrientView: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack {
            Text(name)
                .font(.caption)
                .foregroundStyle(Color("AppSecondaryColor"))
            Text(value)
        }
    }
}


#Preview {
    AnalyzeView(
        store: Store(initialState: AnalyzeFeature.State()) {
            AnalyzeFeature()
        }
    )
}
