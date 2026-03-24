import Foundation
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var quoteCounts: [Int64: Int] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = DatabaseService.shared

    init() {
        loadBooks()
    }

    func loadBooks() {
        isLoading = true
        errorMessage = nil

        do {
            books = try db.fetchAllBooks()
            for book in books {
                quoteCounts[book.id] = try db.quoteCount(forBookId: book.id)
            }
        } catch {
            errorMessage = "Failed to load books: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func addBook(_ book: Book, quoteText: String, pageImage: UIImage?) {
        do {
            let bookId = try db.insertBook(book)

            if let image = pageImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                let filename = "page_\(bookId)_\(Date().timeIntervalSince1970).jpg"
                let path = try db.saveImage(imageData, filename: filename)
                let quote = Quote(bookId: bookId, text: quoteText, pageImagePath: path)
                try db.insertQuote(quote)
            } else {
                let quote = Quote(bookId: bookId, text: quoteText)
                try db.insertQuote(quote)
            }

            loadBooks()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }

    func deleteBook(_ book: Book) {
        do {
            if let coverPath = book.coverImagePath {
                db.deleteImage(atPath: coverPath)
            }
            try db.deleteBook(id: book.id)
            loadBooks()
        } catch {
            errorMessage = "Failed to delete book: \(error.localizedDescription)"
        }
    }

    func refreshQuoteCount(for bookId: Int64) {
        do {
            quoteCounts[bookId] = try db.quoteCount(forBookId: bookId)
        } catch {
            // silent fail
        }
    }
}
