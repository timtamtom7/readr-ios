import Foundation
import SQLite

// MARK: - Book Note
struct BookNote: Identifiable, Equatable {
    let id: Int64
    let bookId: Int64
    var text: String
    var pageNumber: Int?
    var highlightText: String?
    var createdAt: Date
    var updatedAt: Date

    init(id: Int64 = 0, bookId: Int64, text: String, pageNumber: Int? = nil, highlightText: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.bookId = bookId
        self.text = text
        self.pageNumber = pageNumber
        self.highlightText = highlightText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Quote Highlight
struct QuoteHighlight: Identifiable, Equatable {
    let id: Int64
    let quoteId: Int64
    var startOffset: Int
    var endOffset: Int
    var colorHex: String

    init(id: Int64 = 0, quoteId: Int64, startOffset: Int, endOffset: Int, colorHex: String = "f59e0b") {
        self.id = id
        self.quoteId = quoteId
        self.startOffset = startOffset
        self.endOffset = endOffset
        self.colorHex = colorHex
    }
}

// MARK: - Citation Style
enum CitationStyle: String, CaseIterable, Identifiable {
    case apa = "APA"
    case mla = "MLA"
    case chicago = "Chicago"
    case bibtex = "BibTeX"

    var id: String { rawValue }
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable, Identifiable {
    case pdf = "PDF"
    case readwise = "Readwise"
    case notion = "Notion"
    case obsidian = "Obsidian"
    case citations = "Citations"

    var id: String { rawValue }
}

// MARK: - Book Recommendation
struct BookRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let reason: String
    let coverColor: String
}
