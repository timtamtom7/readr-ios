import Foundation
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var collections: [Collection] = []
    @Published var quoteCounts: [Int64: Int] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Search
    @Published var searchQuery = ""
    @Published var searchResults: [SearchResult] = []
    @Published var isSearching = false

    // Collection filter
    @Published var selectedCollectionId: Int64? = nil
    @Published var collectionBooks: [Book] = []

    var totalQuoteCount: Int {
        quoteCounts.values.reduce(0, +)
    }

    private let db = DatabaseService.shared

    init() {
        loadBooks()
        loadCollections()
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

    func loadCollections() {
        do {
            collections = try db.fetchAllCollections()
        } catch {
            // silent fail
        }
    }

    func addBook(_ book: Book, quoteText: String, pageImage: UIImage?) {
        do {
            let bookId = try db.insertBook(book)

            if let image = pageImage, let imageData = image.jpegData(compressionQuality: 0.8) {
                let filename = "page_\(bookId)_\(Date().timeIntervalSince1970).jpg"
                let path = try db.saveImage(imageData, filename: filename)
                let quote = Quote(bookId: bookId, text: quoteText, pageImagePath: path)
                try db.insertQuote(quote)

                // Update widget with this new quote
                WidgetDataUpdater.updateWidgetQuote(quote: quoteText, bookTitle: book.title, author: book.author)
            } else {
                let quote = Quote(bookId: bookId, text: quoteText)
                try db.insertQuote(quote)

                // Update widget with this new quote
                WidgetDataUpdater.updateWidgetQuote(quote: quoteText, bookTitle: book.title, author: book.author)
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

    // MARK: - Collection Management

    func loadBooksForCollection(_ collectionId: Int64) {
        do {
            collectionBooks = try db.fetchBooksForCollection(collectionIdValue: collectionId)
            for book in collectionBooks {
                quoteCounts[book.id] = try db.quoteCount(forBookId: book.id)
            }
        } catch {
            errorMessage = "Failed to load collection: \(error.localizedDescription)"
        }
    }

    func addBookToCollection(bookId: Int64, collectionId: Int64) {
        do {
            try db.addBookToCollection(bookIdValue: bookId, collectionIdValue: collectionId)
        } catch {
            errorMessage = "Failed to add to collection: \(error.localizedDescription)"
        }
    }

    func removeBookFromCollection(bookId: Int64, collectionId: Int64) {
        do {
            try db.removeBookFromCollection(bookIdValue: bookId, collectionIdValue: collectionId)
        } catch {
            errorMessage = "Failed to remove from collection: \(error.localizedDescription)"
        }
    }

    func moveBookToCollection(bookId: Int64, collectionId: Int64) {
        do {
            try db.moveBookToCollection(bookIdValue: bookId, collectionIdValue: collectionId)
        } catch {
            errorMessage = "Failed to move book: \(error.localizedDescription)"
        }
    }

    func createCollection(name: String, iconName: String) {
        do {
            try db.insertCollection(Collection(name: name, iconName: iconName, isSystem: false))
            loadCollections()
        } catch {
            errorMessage = "Failed to create collection: \(error.localizedDescription)"
        }
    }

    func deleteCollection(_ collection: Collection) {
        guard !collection.isSystem else { return }
        do {
            try db.deleteCollection(id: collection.id)
            loadCollections()
        } catch {
            errorMessage = "Failed to delete collection: \(error.localizedDescription)"
        }
    }

    func collectionsForBook(_ bookId: Int64) -> [Collection] {
        (try? db.fetchCollectionsForBook(bookIdValue: bookId)) ?? []
    }

    // MARK: - Search

    func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        do {
            searchResults = try db.search(query: searchQuery.trimmingCharacters(in: .whitespacesAndNewlines))
        } catch {
            searchResults = []
        }
        isSearching = false
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        isSearching = false
    }
}
