import SwiftUI
import MarkdownUI

struct FullMarkdownView: View {
    let markdown: String
    
    var body: some View {
        Markdown(markdown)
            .markdownTheme(.gitHub) // 원하는 테마 선택
            // 마크다운 전체 영역이 잘 보이도록 설정
            .frame(maxWidth: .infinity, alignment: .leading)
            // 이미지가 있을 경우 처리
            // 링크 스타일 지정
    }
}
