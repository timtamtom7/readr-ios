import Foundation
import SQLite

final class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()

    private var db: Connection?

    // Tables
    private let books = Table("books")
    private let quotes = Table("quotes")

    // Book columns
    private let bookId = Expression<Int64>("id")
    private let bookTitle = Expression<String>("title")
    private let bookAuthor = Expression<String>("author")
    private let bookCoverPath = Expression<String?>("cover_image_path")
    private let bookCreatedAt = Expression<Date>("created_at")

    // Quote columns
    private let quoteId = Expression<Int64>("id")
    private let quoteBookId = Expression<Int64>("book_id")
    private let quoteText = Expression<String>("text")
    private let quotePagePath = Expression<String?>("page_image_path")
    private let quoteCreatedAt = Expression<Date>("created_at")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("readr.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(books.create(ifNotExists: true) { t in
            t.column(bookId, primaryKey: .autoincrement)
            t.column(bookTitle)
            t.column(bookAuthor, defaultValue: "")
            t.column(bookCoverPath)
            t.column(bookCreatedAt, defaultValue: Date())
        })

        try db?.run(quotes.create(ifNotExists: true) { t in
            t.column(quoteId, primaryKey: .autoincrement)
            t.column(quoteBookId)
            t.column(quoteText)
            t.column(quotePagePath)
            t.column(quoteCreatedAt, defaultValue: Date())
            t.foreignKey(quoteBookId, references: books, bookId, delete: .cascade)
        })
    }

    // MARK: - Book Operations

    @discardableResult
    nonisolated func insertBook(_ book: Book) throws -> Int64 {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let insert = books.insert(
            bookTitle <- book.title,
            bookAuthor <- book.author,
            bookCoverPath <- book.coverImagePath,
            bookCreatedAt <- book.createdAt
        )
        return try db.run(insert)
    }

    nonisolated func fetchAllBooks() throws -> [Book] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [Book] = []
        for row in try db.prepare(books.order(bookCreatedAt.desc)) {
            let book = Book(
                id: row[bookId],
                title: row[bookTitle],
                author: row[bookAuthor],
                coverImagePath: row[bookCoverPath],
                createdAt: row[bookCreatedAt]
            )
            result.append(book)
        }
        return result
    }

    nonisolated func fetchBook(id: Int64) throws -> Book? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = books.filter(bookId == id)
        guard let row = try db.pluck(query) else { return nil }

        return Book(
            id: row[bookId],
            title: row[bookTitle],
            author: row[bookAuthor],
            coverImagePath: row[bookCoverPath],
            createdAt: row[bookCreatedAt]
        )
    }

    nonisolated func deleteBook(id: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let bookToDelete = books.filter(bookId == id)
        try db.run(bookToDelete.delete())
    }

    // MARK: - Quote Operations

    @discardableResult
    nonisolated func insertQuote(_ quote: Quote) throws -> Int64 {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let insert = quotes.insert(
            quoteBookId <- quote.bookId,
            quoteText <- quote.text,
            quotePagePath <- quote.pageImagePath,
            quoteCreatedAt <- quote.createdAt
        )
        return try db.run(insert)
    }

    nonisolated func fetchQuotes(forBookId bookIdValue: Int64) throws -> [Quote] {
        guard let db = db else { throw DatabaseError.connectionFailed }

        var result: [Quote] = []
        let query = quotes.filter(quoteBookId == bookIdValue).order(quoteCreatedAt.desc)
        for row in try db.prepare(query) {
            let quote = Quote(
                id: row[quoteId],
                bookId: row[quoteBookId],
                text: row[quoteText],
                pageImagePath: row[quotePagePath],
                createdAt: row[quoteCreatedAt]
            )
            result.append(quote)
        }
        return result
    }

    nonisolated func quoteCount(forBookId bookIdValue: Int64) throws -> Int {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let query = quotes.filter(quoteBookId == bookIdValue)
        return try db.scalar(query.count)
    }

    nonisolated func deleteQuote(id: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let quoteToDelete = quotes.filter(quoteId == id)
        try db.run(quoteToDelete.delete())
    }

    // MARK: - File Storage

    nonisolated func saveImage(_ imageData: Data, filename: String) throws -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDir = documentsPath.appendingPathComponent("images", isDirectory: true)

        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }

        let filePath = imagesDir.appendingPathComponent(filename)
        try imageData.write(to: filePath)
        return filePath.path
    }

    nonisolated func loadImage(atPath path: String) -> Data? {
        return FileManager.default.contents(atPath: path)
    }

    nonisolated func deleteImage(atPath path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}

enum DatabaseError: Error {
    case connectionFailed
    case insertFailed
    case fetchFailed
}
