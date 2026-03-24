import Foundation
import SQLite
import SwiftUI

// MARK: - Tag
struct Tag: Identifiable, Equatable, Hashable {
    let id: Int64
    var name: String
    var colorHex: String

    init(id: Int64 = 0, name: String, colorHex: String = "c87b4f") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - QuoteTag (junction)
struct QuoteTag: Identifiable {
    let id: Int64
    let quoteId: Int64
    let tagId: Int64
}

// MARK: - Collection (Shelf)
struct Collection: Identifiable, Equatable {
    let id: Int64
    var name: String
    var iconName: String
    var sortOrder: Int
    var isSystem: Bool  // true for Want to Read, Currently Reading, Finished

    init(id: Int64 = 0, name: String, iconName: String = "bookmark", sortOrder: Int = 0, isSystem: Bool = false) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.sortOrder = sortOrder
        self.isSystem = isSystem
    }
}

// MARK: - BookCollection (junction)
struct BookCollection: Identifiable {
    let id: Int64
    let bookId: Int64
    let collectionId: Int64
}

// MARK: - SearchResult
struct SearchResult: Identifiable {
    let id = UUID()
    let book: Book
    let quote: Quote?
}

// MARK: - Database Service
final class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()

    private var db: Connection?

    // Tables
    private let books = Table("books")
    private let quotes = Table("quotes")
    private let collections = Table("collections")
    private let bookCollections = Table("book_collections")
    private let tags = Table("tags")
    private let quoteTags = Table("quote_tags")

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

    // Collection columns
    private let colId = Expression<Int64>("id")
    private let colName = Expression<String>("name")
    private let colIconName = Expression<String>("icon_name")
    private let colSortOrder = Expression<Int>("sort_order")
    private let colIsSystem = Expression<Bool>("is_system")

    // BookCollection columns
    private let bcId = Expression<Int64>("id")
    private let bcBookId = Expression<Int64>("book_id")
    private let bcCollectionId = Expression<Int64>("collection_id")

    // Tag columns
    private let tagId = Expression<Int64>("id")
    private let tagName = Expression<String>("name")
    private let tagColorHex = Expression<String>("color_hex")

    // QuoteTag columns
    private let qtId = Expression<Int64>("id")
    private let qtQuoteId = Expression<Int64>("quote_id")
    private let qtTagId = Expression<Int64>("tag_id")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("readr.sqlite3").path
            db = try Connection(dbPath)
            try createTables()
            try seedSystemCollections()
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

        try db?.run(collections.create(ifNotExists: true) { t in
            t.column(colId, primaryKey: .autoincrement)
            t.column(colName)
            t.column(colIconName, defaultValue: "bookmark")
            t.column(colSortOrder, defaultValue: 0)
            t.column(colIsSystem, defaultValue: false)
        })

        try db?.run(bookCollections.create(ifNotExists: true) { t in
            t.column(bcId, primaryKey: .autoincrement)
            t.column(bcBookId)
            t.column(bcCollectionId)
            t.foreignKey(bcBookId, references: books, bookId, delete: .cascade)
            t.foreignKey(bcCollectionId, references: collections, colId, delete: .cascade)
            t.unique(bcBookId, bcCollectionId)
        })

        try db?.run(tags.create(ifNotExists: true) { t in
            t.column(tagId, primaryKey: .autoincrement)
            t.column(tagName)
            t.column(tagColorHex, defaultValue: "c87b4f")
        })

        try db?.run(quoteTags.create(ifNotExists: true) { t in
            t.column(qtId, primaryKey: .autoincrement)
            t.column(qtQuoteId)
            t.column(qtTagId)
            t.foreignKey(qtQuoteId, references: quotes, quoteId, delete: .cascade)
            t.foreignKey(qtTagId, references: tags, tagId, delete: .cascade)
            t.unique(qtQuoteId, qtTagId)
        })

        // FTS5 for search
        try db?.run("CREATE VIRTUAL TABLE IF NOT EXISTS quotes_fts USING fts5(text), content='quotes', content_rowid='id'")
        try db?.run("CREATE VIRTUAL TABLE IF NOT EXISTS books_fts USING fts5(title, author), content='books', content_rowid='id'")
    }

    private func seedSystemCollections() throws {
        guard let db = db else { return }
        let count = try db.scalar(collections.count)
        if count > 0 { return }

        let systemCollections = [
            ("Want to Read", "bookmark", 0, true),
            ("Currently Reading", "book", 1, true),
            ("Finished", "checkmark.bookmark", 2, true),
            ("Abandoned", "xmark.book", 3, true)
        ]
        for (name, icon, order, system) in systemCollections {
            try db.run(collections.insert(
                colName <- name,
                colIconName <- icon,
                colSortOrder <- order,
                colIsSystem <- system
            ))
        }
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

    nonisolated func updateBook(_ book: Book) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let toUpdate = books.filter(bookId == book.id)
        try db.run(toUpdate.update(
            bookTitle <- book.title,
            bookAuthor <- book.author,
            bookCoverPath <- book.coverImagePath
        ))
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

    // MARK: - Collection Operations

    nonisolated func fetchAllCollections() throws -> [Collection] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Collection] = []
        for row in try db.prepare(collections.order(colSortOrder.asc)) {
            result.append(Collection(
                id: row[colId],
                name: row[colName],
                iconName: row[colIconName],
                sortOrder: row[colSortOrder],
                isSystem: row[colIsSystem]
            ))
        }
        return result
    }

    @discardableResult
    nonisolated func insertCollection(_ collection: Collection) throws -> Int64 {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let maxOrder = try db.scalar(collections.select(colSortOrder.max)) ?? 0
        let insert = collections.insert(
            colName <- collection.name,
            colIconName <- collection.iconName,
            colSortOrder <- maxOrder + 1,
            colIsSystem <- collection.isSystem
        )
        return try db.run(insert)
    }

    nonisolated func deleteCollection(id: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toDelete = collections.filter(colId == id && colIsSystem == false)
        try db.run(toDelete.delete())
    }

    nonisolated func updateCollection(_ collection: Collection) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toUpdate = collections.filter(colId == collection.id)
        try db.run(toUpdate.update(
            colName <- collection.name,
            colIconName <- collection.iconName
        ))
    }

    // MARK: - BookCollection Operations

    nonisolated func fetchCollectionsForBook(bookIdValue: Int64) throws -> [Collection] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Collection] = []
        let query = collections
            .join(bookCollections, on: colId == bcCollectionId)
            .filter(bcBookId == bookIdValue)
            .order(colSortOrder.asc)
        for row in try db.prepare(query) {
            result.append(Collection(
                id: row[colId],
                name: row[colName],
                iconName: row[colIconName],
                sortOrder: row[colSortOrder],
                isSystem: row[colIsSystem]
            ))
        }
        return result
    }

    nonisolated func fetchBooksForCollection(collectionIdValue: Int64) throws -> [Book] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Book] = []
        let query = books
            .join(bookCollections, on: bookId == bcBookId)
            .filter(bcCollectionId == collectionIdValue)
            .order(bookCreatedAt.desc)
        for row in try db.prepare(query) {
            result.append(Book(
                id: row[bookId],
                title: row[bookTitle],
                author: row[bookAuthor],
                coverImagePath: row[bookCoverPath],
                createdAt: row[bookCreatedAt]
            ))
        }
        return result
    }

    nonisolated func addBookToCollection(bookIdValue: Int64, collectionIdValue: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        try db.run(bookCollections.insert(or: .ignore,
            bcBookId <- bookIdValue,
            bcCollectionId <- collectionIdValue
        ))
    }

    nonisolated func removeBookFromCollection(bookIdValue: Int64, collectionIdValue: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toRemove = bookCollections.filter(bcBookId == bookIdValue && bcCollectionId == collectionIdValue)
        try db.run(toRemove.delete())
    }

    nonisolated func moveBookToCollection(bookIdValue: Int64, collectionIdValue: Int64) throws {
        try removeBookFromCollection(bookIdValue: bookIdValue, collectionIdValue: collectionIdValue)
        try addBookToCollection(bookIdValue: bookIdValue, collectionIdValue: collectionIdValue)
    }

    // MARK: - Search

    nonisolated func search(query: String) throws -> [SearchResult] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var results: [SearchResult] = []
        let likePattern = "%\(trimmed)%"

        // Search books using SQLite.swift query builder
        let bookQuery = books.filter(bookTitle.like(likePattern) || bookAuthor.like(likePattern)).limit(20)
        for row in try db.prepare(bookQuery) {
            let book = Book(
                id: row[bookId],
                title: row[bookTitle],
                author: row[bookAuthor],
                coverImagePath: row[bookCoverPath],
                createdAt: row[bookCreatedAt]
            )
            results.append(SearchResult(book: book, quote: nil))
        }

        // Search quotes
        let quoteQuery = quotes.filter(quoteText.like(likePattern)).limit(30)
        for row in try db.prepare(quoteQuery) {
            let fetchedBook = try fetchBook(id: row[quoteBookId])
            let quote = Quote(
                id: row[quoteId],
                bookId: row[quoteBookId],
                text: row[quoteText],
                pageImagePath: row[quotePagePath],
                createdAt: row[quoteCreatedAt]
            )
            results.append(SearchResult(book: fetchedBook ?? Book(title: "Unknown Book"), quote: quote))
        }

        return results
    }

    nonisolated func fetchRandomQuote() throws -> (Quote, Book)? {
        guard let db = db else { throw DatabaseError.connectionFailed }

        let sql = """
            SELECT q.id, q.book_id, q.text, q.page_image_path, q.created_at,
                   b.id, b.title, b.author, b.cover_image_path, b.created_at
            FROM quotes q
            JOIN books b ON q.book_id = b.id
            ORDER BY RANDOM()
            LIMIT 1
        """

        for row in try db.prepare(sql) {
            let book = Book(
                id: row[5] as! Int64,
                title: row[6] as? String ?? "",
                author: row[7] as? String ?? "",
                coverImagePath: row[8] as? String,
                createdAt: Date(timeIntervalSince1970: (row[9] as? Double) ?? Date().timeIntervalSince1970)
            )
            let quote = Quote(
                id: row[0] as! Int64,
                bookId: row[1] as! Int64,
                text: row[2] as? String ?? "",
                pageImagePath: row[3] as? String,
                createdAt: Date(timeIntervalSince1970: (row[4] as? Double) ?? Date().timeIntervalSince1970)
            )
            return (quote, book)
        }
        return nil
    }

    nonisolated func fetchAllQuotes() throws -> [Quote] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Quote] = []
        for row in try db.prepare(quotes.order(quoteCreatedAt.desc)) {
            result.append(Quote(
                id: row[quoteId],
                bookId: row[quoteBookId],
                text: row[quoteText],
                pageImagePath: row[quotePagePath],
                createdAt: row[quoteCreatedAt]
            ))
        }
        return result
    }

    // MARK: - Tag Operations

    nonisolated func fetchAllTags() throws -> [Tag] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Tag] = []
        for row in try db.prepare(tags.order(tagName.asc)) {
            result.append(Tag(
                id: row[tagId],
                name: row[tagName],
                colorHex: row[tagColorHex]
            ))
        }
        return result
    }

    @discardableResult
    nonisolated func insertTag(_ tag: Tag) throws -> Int64 {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let insert = tags.insert(
            tagName <- tag.name,
            tagColorHex <- tag.colorHex
        )
        return try db.run(insert)
    }

    nonisolated func deleteTag(id: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toDelete = tags.filter(tagId == id)
        try db.run(toDelete.delete())
    }

    nonisolated func updateTag(_ tag: Tag) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toUpdate = tags.filter(tagId == tag.id)
        try db.run(toUpdate.update(
            tagName <- tag.name,
            tagColorHex <- tag.colorHex
        ))
    }

    nonisolated func fetchTagsForQuote(quoteIdValue: Int64) throws -> [Tag] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Tag] = []
        let query = tags
            .join(quoteTags, on: tagId == qtTagId)
            .filter(qtQuoteId == quoteIdValue)
            .order(tagName.asc)
        for row in try db.prepare(query) {
            result.append(Tag(
                id: row[tagId],
                name: row[tagName],
                colorHex: row[tagColorHex]
            ))
        }
        return result
    }

    nonisolated func addTagToQuote(quoteIdValue: Int64, tagIdValue: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        try db.run(quoteTags.insert(or: .ignore,
            qtQuoteId <- quoteIdValue,
            qtTagId <- tagIdValue
        ))
    }

    nonisolated func removeTagFromQuote(quoteIdValue: Int64, tagIdValue: Int64) throws {
        guard let db = db else { throw DatabaseError.connectionFailed }
        let toRemove = quoteTags.filter(qtQuoteId == quoteIdValue && qtTagId == tagIdValue)
        try db.run(toRemove.delete())
    }

    nonisolated func fetchQuotesForTag(tagIdValue: Int64) throws -> [Quote] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [Quote] = []
        let query = quotes
            .join(quoteTags, on: quoteId == qtQuoteId)
            .filter(qtTagId == tagIdValue)
            .order(quoteCreatedAt.desc)
        for row in try db.prepare(query) {
            result.append(Quote(
                id: row[quoteId],
                bookId: row[quoteBookId],
                text: row[quoteText],
                pageImagePath: row[quotePagePath],
                createdAt: row[quoteCreatedAt]
            ))
        }
        return result
    }

    nonisolated func fetchAllTagsWithCounts() throws -> [(Tag, Int)] {
        guard let db = db else { throw DatabaseError.connectionFailed }
        var result: [(Tag, Int)] = []
        for row in try db.prepare(tags.order(tagName.asc)) {
            let tag = Tag(id: row[tagId], name: row[tagName], colorHex: row[tagColorHex])
            let count = try db.scalar(quoteTags.filter(qtTagId == row[tagId]).count)
            result.append((tag, count))
        }
        return result
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
