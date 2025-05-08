import SwiftUI
import ComposableArchitecture

struct AnalyzeView: View {
    let store: StoreOf<AnalyzeFeature>
    
    // 테스트 코드
    @State private var isSheetPresented = false

        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // TODO: - 신체 정보, 식단의 유무에 따라 다른 뷰를 이용
                    // BodyInfoView, BodyInfoEmptyView
                    // MealPlanEmptyView,
                }
                .navigationTitle("분석")
                .navigationBarTitleDisplayMode(.inline)
                // 해당 코드 주석 처리 후, toolbar와 뷰 겹침 문제 해결
//                .containerRelativeFrame([.horizontal, .vertical])
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
                        isSheetPresented = true
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
            .sheet(isPresented: $isSheetPresented) {
                AddDietView()
            }
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
