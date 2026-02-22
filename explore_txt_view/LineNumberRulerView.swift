import AppKit

class LineNumberRulerView: NSRulerView {
    
    var font: NSFont = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    
    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!, orientation: .verticalRuler)
        self.clientView = textView
        self.ruleThickness = 40
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }
        
        let contentBounds = self.bounds
        NSColor.windowBackgroundColor.setFill()
        contentBounds.fill()
        
        let separator = NSBezierPath()
        separator.move(to: NSPoint(x: contentBounds.maxX - 0.5, y: contentBounds.minY))
        separator.line(to: NSPoint(x: contentBounds.maxX - 0.5, y: contentBounds.maxY))
        NSColor.separatorColor.setStroke()
        separator.stroke()
        
        let visibleRect = textView.visibleRect
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        let textString = textView.string as NSString
        
        var lineNumber = 1
        // Calculate line number up to the visible start
        let stringToVisible = textString.substring(with: NSRange(location: 0, length: characterRange.location))
        lineNumber = stringToVisible.components(separatedBy: .newlines).count
        
        var currentGlyphIndex = glyphRange.location
        while currentGlyphIndex < NSMaxRange(glyphRange) {
            let currentCharacterIndex = layoutManager.characterIndexForGlyph(at: currentGlyphIndex)
            let lineRange = textString.lineRange(for: NSRange(location: currentCharacterIndex, length: 0))
            let lineGlyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: currentGlyphIndex, effectiveRange: nil)
            
            let lineNumberString = "\(lineNumber)" as NSString
            let size = lineNumberString.size(withAttributes: [.font: font])
            
            let drawPoint = NSPoint(x: ruleThickness - size.width - 5, y: lineRect.minY - visibleRect.minY + textView.textContainerOrigin.y)
            
            lineNumberString.draw(at: drawPoint, withAttributes: [
                .font: font,
                .foregroundColor: NSColor.tertiaryLabelColor
            ])
            
            lineNumber += 1
            currentGlyphIndex = NSMaxRange(lineGlyphRange)
        }
    }
}
