import SwiftUI
import UIKit
import Down

struct AttributedTextView: UIViewRepresentable {
    let markdown: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.widthTracksTextView = true
        textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let htmlString: String
        do {
            htmlString = try Down(markdownString: markdown).toHTML()
        } catch {
            uiView.text = markdown
            return
        }

        let styledHtml = """
        <style>
            body { font-size: 16px; line-height: 1.6; font-family: -apple-system; color: #000000; }
            h2 { font-size: 18px; font-weight: bold; margin-top: 1em; }
            code, pre { background-color: #f6f6f6; padding: 4px; border-radius: 4px; }
        </style>
        <body>\(htmlString)</body>
        """

        if let data = styledHtml.data(using: .utf8),
           let attributed = try? NSMutableAttributedString(
               data: data,
               options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ],
               documentAttributes: nil) {
            uiView.attributedText = attributed
        } else {
            uiView.text = markdown
        }
    }
}
