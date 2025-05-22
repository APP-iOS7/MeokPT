import SwiftUI
import ComposableArchitecture

struct MealSelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    @Bindable var store: StoreOf<MealSelectionFeature>

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 내비게이션 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                Spacer()
                Text("식단 선택")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding()

            // 스위치 스타일 토글
            ZStack(alignment: store.isFavoriteTab ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 194, height: 26)

                RoundedRectangle(cornerRadius: 9)
                    .fill(Color.white)
                    .frame(width: 97, height: 26) // 절반 크기
                    .shadow(radius: 1)

                HStack(spacing: 0) {
                    Text("전체")
                        .frame(width: 97, height: 26)
                        .foregroundColor(store.isFavoriteTab ? .gray : .black)
                    Text("즐겨찾기")
                        .frame(width: 97, height: 26)
                        .foregroundColor(store.isFavoriteTab ? .black : .gray)
                }
                .font(.system(size: 13, weight: .medium))
            }
            .padding(.vertical, 16)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    store.isFavoriteTab.toggle()
                }
            }

            // 식단 카드 (3개, radius 20)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<5) { _ in
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .frame(height: 162)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            Spacer()
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
