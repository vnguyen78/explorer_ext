import SwiftUI
import AppKit

struct SyntaxEditorDetailView: NSViewRepresentable {
    @Binding var text: String
    var fileExtension: String
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        
        let textView = NSTextView()
        textView.autoresizingMask = [.width]
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.delegate = context.coordinator
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        
        scrollView.documentView = textView
        
        let rulerView = LineNumberRulerView(textView: textView)
        scrollView.verticalRulerView = rulerView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        context.coordinator.parent = self
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            applyHighlighting(to: textView.textStorage)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SyntaxEditorDetailView
        
        init(_ parent: SyntaxEditorDetailView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.applyHighlighting(to: textView.textStorage)
        }
    }
    
    private func applyHighlighting(to textStorage: NSTextStorage?) {
        guard let textStorage = textStorage else { return }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        let string = textStorage.string
        
        // Reset styles
        textStorage.addAttributes([
            .foregroundColor: NSColor.textColor,
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        ], range: fullRange)
        
        if fileExtension == "py" {
            // Keywords
            let keywords = ["def", "class", "import", "from", "return", "if", "else", "elif", "for", "while", "in", "and", "or", "not", "True", "False", "None"]
            for keyword in keywords {
                let pattern = "\\b\(keyword)\\b"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    regex.enumerateMatches(in: string, range: fullRange) { match, _, _ in
                        if let range = match?.range {
                            textStorage.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: range)
                            textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), range: range)
                        }
                    }
                }
            }
            // Strings
            if let regex = try? NSRegularExpression(pattern: "(\"([^\"]*)\"|'([^']*)')") {
                regex.enumerateMatches(in: string, range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemRed, range: range)
                    }
                }
            }
            // Comments
            if let regex = try? NSRegularExpression(pattern: "#.*") {
                regex.enumerateMatches(in: string, range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: range)
                    }
                }
            }
        } else if fileExtension == "md" {
            // Headers
            if let regex = try? NSRegularExpression(pattern: "^#{1,6}\\s.*", options: .anchorsMatchLines) {
                regex.enumerateMatches(in: string, range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        textStorage.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: range)
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 16, weight: .bold), range: range)
                    }
                }
            }
            // Bold
            if let regex = try? NSRegularExpression(pattern: "\\*\\*[^*]+\\*\\*") {
                regex.enumerateMatches(in: string, range: fullRange) { match, _, _ in
                    if let range = match?.range {
                        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold), range: range)
                    }
                }
            }
        }
    }
}
