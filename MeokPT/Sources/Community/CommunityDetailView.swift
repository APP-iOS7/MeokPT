import SwiftUI

struct CommunityDetailView: View {
    @Environment(\.dismiss) var dismiss

    var postTitle: String
    var postBody: String
    var imageColor: Color

    var body: some View {
        VStack(spacing: 0) {
            // 🔙 상단 커스텀 내비게이션 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                Spacer()
                Text("커뮤니티")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 👤 프로필
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 55, height: 55)
                        VStack(alignment: .leading) {
                            Text("닉네임")
                                .font(.subheadline)
                                .bold()
                            Text("4월 30일")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    // 📷 이미지
                    imageColor
                        .frame(height: 210)
                        .cornerRadius(20)

                    // 📝 본문
                    Text(postBody)
                        .font(.body)

                    // 🍱 식단 카드
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 162)
                        .cornerRadius(20)

                    // ➕ 버튼
                    Button(action: {}) {
                        Text("식단 리스트에 추가")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#090909"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#FAAE2B"))
                            .cornerRadius(40)
                    }
                }
                .padding()
            }
        }
        .background(Color("AppBackgroundColor"))
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
