import Cocoa
import Quartz

class ReportGenerator {
    func generatePDFReport(from text: String, outputPath: URL) -> Bool {
        let pdfData = NSMutableData()
        let bounds = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        
        guard let consumer = CGDataConsumer(data: pdfData),
              let context = CGContext(consumer: consumer, mediaBox: &bounds, nil) else {
            return false
        }
        
        context.beginPDFPage(nil)
        
        // Set up text attributes
        let textFont = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        let textColor = NSColor.black
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: textFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Create attributed string
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        // Create text frame
        let frameRect = bounds.insetBy(dx: 36, dy: 36) // 0.5 inch margins
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        let framePath = CGPath(rect: frameRect, transform: nil)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), framePath, nil)
        
        // Draw the frame
        CTFrameDraw(frame, context)
        
        context.endPDFPage()
        context.closePDF()
        
        // Save to file
        do {
            try pdfData.write(to: outputPath, options: .atomic)
            return true
        } catch {
            print("Error saving PDF: \(error)")
            return false
        }
    }
}