import SwiftUI

struct CommunityWriteView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // 🔙 커스텀 뒤로가기 버튼 + 제목
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
                // 오른쪽 공간 확보용
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
           
            
            // 제목 입력 (밑줄 스타일)
            VStack(alignment: .leading, spacing: 4) {
                TextField("제목을 입력해주세요.", text: $title)
                    .padding(.horizontal, 4)
                    .foregroundColor(.black)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.horizontal)

            // 내용 입력
            ZStack(alignment: .topLeading) {
                // 내용이 없을 때만 보이도록 설정
                if content.isEmpty {
                    Text("내용을 입력해주세요.")
                        .foregroundColor(.gray.opacity(0.5)) // 색상 조정
                        .padding(8)
                        .padding(.top, 6) // 조금 더 위로 올려서 공간 확보
                }
                
                TextEditor(text: $content)
                    .frame(height: 108)
                    .padding(4)
                    .background(Color.white)  // 배경을 흰색으로 설정
                    .cornerRadius(10)
                    .opacity(content.isEmpty ? 0.9 : 1) // 내용이 있으면 TextEditor만 보이도록 설정
            }
            .padding(.horizontal)


            // 식단 선택 (수정된 부분: HStack으로 변경)
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(height: 160)
                .overlay(
                    HStack {
                        Text("＋")
                            .font(.system(size: 70, weight: .medium))
                            .padding(.trailing, 6)
                        Text("식단 선택")
                            .foregroundColor(.black)
                    }
                    .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3))
                )
                .padding(.horizontal)

            // 사진 선택
            VStack(alignment: .leading, spacing: 8) {
                Text("사진 (선택)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(height: 210)
                    .overlay(
                        Image(systemName: "photo.badge.plus") // ✅ SF Symbol 아이콘 사용
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
            .padding(.horizontal)

            Spacer()

            // 글 등록 버튼
            Button(action: {
                // 글 등록 처리
            }) {
                Text("글 등록")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "#F8B84E"))
                    .cornerRadius(20)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color("AppBackgroundColor").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}
