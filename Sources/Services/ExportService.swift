import Foundation
import UIKit
import PDFKit

// MARK: - Export Service
final class ExportService: @unchecked Sendable {
    static let shared = ExportService()

    private init() {}

    // MARK: - PDF Export

    func exportQuotesToPDF(quotes: [(Quote, Book)]) -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 72

        let pdfMetaData = [
            kCGPDFContextCreator: "Readr",
            kCGPDFContextAuthor: "Readr App",
            kCGPDFContextTitle: "My Quotes"
        ] as [String: Any]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var currentY: CGFloat = margin
            var pageNum = 1

            func startNewPage() {
                context.beginPage()
                currentY = margin

                // Header
                let headerFont = UIFont.systemFont(ofSize: 10, weight: .medium)
                let headerText = "Readr — My Quotes"
                let headerRect = CGRect(x: margin, y: margin - 20, width: pageWidth - 2 * margin, height: 20)
                headerText.draw(in: headerRect, withAttributes: [
                    .font: headerFont,
                    .foregroundColor: UIColor.gray
                ])

                // Page number
                let pageText = "Page \(pageNum)"
                let pageRect = CGRect(x: pageWidth - margin - 50, y: margin - 20, width: 50, height: 20)
                pageText.draw(in: pageRect, withAttributes: [
                    .font: headerFont,
                    .foregroundColor: UIColor.gray
                ])
                pageNum += 1
            }

            startNewPage()

            for (quote, book) in quotes {
                let quoteFont = UIFont(name: "Georgia", size: 12) ?? UIFont.systemFont(ofSize: 12)
                let bookFont = UIFont.systemFont(ofSize: 10, weight: .medium)
                let dateFont = UIFont.systemFont(ofSize: 9)

                let quoteText = "\"\(quote.text)\""
                let bookText = "\(book.title)" + (book.author.isEmpty ? "" : " — \(book.author)")
                let dateText = quote.createdAt.formatted(date: .long, time: .omitted)

                let maxWidth = pageWidth - 2 * margin

                // Estimate height needed
                let quoteStyle = NSMutableParagraphStyle()
                quoteStyle.lineSpacing = 4
                let quoteAttrs: [NSAttributedString.Key: Any] = [
                    .font: quoteFont,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: quoteStyle
                ]

                let attributedQuote = NSAttributedString(string: quoteText, attributes: quoteAttrs)
                let quoteBounds = attributedQuote.boundingRect(
                    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )

                let attributedBook = NSAttributedString(string: bookText, attributes: [.font: bookFont, .foregroundColor: UIColor.darkGray])
                let bookBounds = attributedBook.boundingRect(
                    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )

                let attributedDate = NSAttributedString(string: dateText, attributes: [.font: dateFont, .foregroundColor: UIColor.gray])
                let dateBounds = attributedDate.boundingRect(
                    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )

                let totalHeight = quoteBounds.height + 8 + bookBounds.height + 4 + dateBounds.height + 32

                if currentY + totalHeight > pageHeight - margin {
                    startNewPage()
                }

                // Draw quote
                let quoteRect = CGRect(x: margin, y: currentY, width: maxWidth, height: quoteBounds.height)
                quoteText.draw(in: quoteRect, withAttributes: quoteAttrs)
                currentY += quoteBounds.height + 8

                // Draw book
                let bookRect = CGRect(x: margin, y: currentY, width: maxWidth, height: bookBounds.height)
                bookText.draw(in: bookRect, withAttributes: [.font: bookFont, .foregroundColor: UIColor.darkGray])
                currentY += bookBounds.height + 4

                // Draw date
                let dateRect = CGRect(x: margin, y: currentY, width: maxWidth, height: dateBounds.height)
                dateText.draw(in: dateRect, withAttributes: [.font: dateFont, .foregroundColor: UIColor.gray])
                currentY += dateBounds.height + 24

                // Divider
                let dividerY = currentY - 12
                context.cgContext.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
                context.cgContext.setLineWidth(0.5)
                context.cgContext.move(to: CGPoint(x: margin, y: dividerY))
                context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: dividerY))
                context.cgContext.strokePath()
            }
        }

        return data
    }

    // MARK: - Citation Formatters

    func formatCitation(quote: Quote, book: Book, style: CitationStyle) -> String {
        switch style {
        case .apa:
            return formatAPA(quote: quote, book: book)
        case .mla:
            return formatMLA(quote: quote, book: book)
        case .chicago:
            return formatChicago(quote: quote, book: book)
        case .bibtex:
            return formatBibTeX(quote: quote, book: book)
        }
    }

    private func formatAPA(quote: Quote, book: Book) -> String {
        let year = Calendar.current.component(.year, from: book.createdAt)
        let page = quote.pageImagePath != nil ? " (p. unknown)" : ""
        return "\"\(quote.text)\" — \(book.author.isEmpty ? "Unknown Author" : book.author), \(book.title) (\(year)).\(page)"
    }

    private func formatMLA(quote: Quote, book: Book) -> String {
        let page = quote.pageImagePath != nil ? ", p. unknown" : ""
        return "\"\(quote.text)\" \(book.author.isEmpty ? "Unknown Author" : book.author). \(book.title). \(Calendar.current.component(.year, from: book.createdAt))\(page)."
    }

    private func formatChicago(quote: Quote, book: Book) -> String {
        let page = quote.pageImagePath != nil ? ", p. unknown" : ""
        return "\"\(quote.text)\" in \(book.author.isEmpty ? "Unknown Author" : book.author), \(book.title) (\(Calendar.current.component(.year, from: book.createdAt)))\(page)."
    }

    private func formatBibTeX(quote: Quote, book: Book) -> String {
        let key = book.title.prefix(4).lowercased().replacingOccurrences(of: " ", with: "") +
                  String(Calendar.current.component(.year, from: book.createdAt))
        let cleanText = quote.text
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "&", with: "\\&")
        let cleanTitle = book.title
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
        let cleanAuthor = book.author
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")

        return """
        @quote{\(key),
          text     = {\(cleanText)},
          author   = {\(cleanAuthor.isEmpty ? "Unknown" : cleanAuthor)},
          title    = {\(cleanTitle)},
          year     = {\(Calendar.current.component(.year, from: book.createdAt))},
          note     = {Captured \(_formatDate(quote.createdAt))}
        }
        """
    }

    private func _formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // MARK: - Citations Export

    func exportAllCitations(quotes: [(Quote, Book)], style: CitationStyle) -> String {
        var lines: [String] = []
        lines.append("# \(style.rawValue) Citations — Exported from Readr")
        lines.append("")
        for (quote, book) in quotes {
            lines.append(formatCitation(quote: quote, book: book, style: style))
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Readwise Export

    func exportToReadwiseCSV(quotes: [(Quote, Book)]) -> String {
        var lines: [String] = ["Quote,Book,Author,Tags,CreatedAt"]
        for (quote, book) in quotes {
            let escapedQuote = quote.text.replacingOccurrences(of: "\"", with: "\"\"")
            let escapedTitle = book.title.replacingOccurrences(of: "\"", with: "\"\"")
            let escapedAuthor = book.author.replacingOccurrences(of: "\"", with: "\"\"")
            lines.append("\"\(escapedQuote)\",\"\(escapedTitle)\",\"\(escapedAuthor)\",\"\",\"\(_formatDate(quote.createdAt))\"")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Obsidian Export

    func exportToObsidianVault(quotes: [(Quote, Book)], vaultPath: String) throws {
        let fileManager = FileManager.default
        let quotesFolder = URL(fileURLWithPath: vaultPath).appendingPathComponent("Readr Quotes", isDirectory: true)

        if !fileManager.fileExists(atPath: quotesFolder.path) {
            try fileManager.createDirectory(at: quotesFolder, withIntermediateDirectories: true)
        }

        for (quote, book) in quotes {
            let safeBookTitle = book.title.replacingOccurrences(of: "/", with: "-")
                .replacingOccurrences(of: ":", with: "-")
            let bookFolder = quotesFolder.appendingPathComponent(safeBookTitle, isDirectory: true)

            if !fileManager.fileExists(atPath: bookFolder.path) {
                try fileManager.createDirectory(at: bookFolder, withIntermediateDirectories: true)
            }

            let dateStr = _formatDate(quote.createdAt)
                .replacingOccurrences(of: " ", with: "-")
                .replacingOccurrences(of: ",", with: "")
            let fileName = "Quote-\(dateStr).md"
            let filePath = bookFolder.appendingPathComponent(fileName)

            var content = "---\n"
            content += "type: quote\n"
            content += "book: \"\(book.title)\"\n"
            content += "author: \"\(book.author.isEmpty ? "Unknown" : book.author)\"\n"
            content += "date: \(_formatDate(quote.createdAt))\n"
            content += "tags: []\n"
            content += "---\n\n"
            content += "> \(quote.text)\n"

            try content.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - Notion Export

    func exportToNotionMarkdown(quotes: [(Quote, Book)]) -> String {
        var output = "# My Quotes — Readr Export\n\n"

        // Group by book
        var byBook: [String: [(Quote, Book)]] = [:]
        for item in quotes {
            let key = "\(item.1.title) — \(item.1.author.isEmpty ? "Unknown" : item.1.author)"
            byBook[key, default: []].append(item)
        }

        for (bookKey, items) in byBook.sorted(by: { $0.key < $1.key }) {
            output += "## \(bookKey)\n\n"
            for (quote, _) in items {
                output += "> \(quote.text)\n\n"
                output += "_Captured: \(_formatDate(quote.createdAt))_\n\n"
            }
            output += "---\n\n"
        }

        return output
    }
}
