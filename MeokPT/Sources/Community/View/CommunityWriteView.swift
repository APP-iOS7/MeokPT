import SwiftUI
import ComposableArchitecture

struct CommunityWriteView: View {
    @Bindable var store: StoreOf<CommunityWriteFeature>
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
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
                Text("내용 작성")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.top, 16)

            // 제목 입력
            VStack(alignment: .leading, spacing: 4) {
                TextField("제목을 입력해주세요.", text: $store.title)
                    .padding(.horizontal, 4)
                    .foregroundColor(.black)

                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
            }

            // 내용 입력
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    if store.content.isEmpty {
                        Text("내용을 입력해주세요.")
                            .foregroundColor(.gray)
                            .padding(.top, 12)
                            .padding(.leading, 10)
                    }

                    TextEditor(text: $store.content)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .frame(height: 108)
                        .opacity(1)
                }
            }
            
            Button(action: {
                store.send(.presentMealSelectionSheet)
            }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 160)
                        .overlay(
                            HStack {
                                Text("＋")
                                    .font(.system(size: 70, weight: .medium))
                                    .padding(.trailing, 6)
                                    .foregroundColor(.black)
                                Text("식단 선택")
                                    .foregroundColor(.black)
                            }
                                .padding()
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }
            
            // 사진 선택
            VStack(alignment: .leading, spacing: 8) {
                Text("사진 (선택)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 210)
                    .overlay(
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 90)
                            .foregroundColor(.black)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3))
                    )
            }

            Spacer()

            // 글 등록 버튼
            Button(action: {
                // 글 등록 처리
            }) {
                Text("글 등록")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .frame(height: 60)
            .background(Color("AppTintColor"))
            .cornerRadius(30)
        }
        .padding(.horizontal, 24)
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarHidden(true)              // ✅ 시스템 네비게이션 숨김
        .navigationBarBackButtonHidden(true)    // ✅ 시스템 뒤로가기 숨김
        .navigationBarTitle("")                 // ✅ 시스템 제목 제거
        .sheet (
            item: $store.scope(state: \.mealSelectionSheet, action: \.mealSelectionAction)) { store in
            NavigationStack {
                MealSelectionView(store: store)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    CommunityWriteView(
        store: Store(initialState: CommunityWriteFeature.State()) {
            CommunityWriteFeature()
        }
    )
}
