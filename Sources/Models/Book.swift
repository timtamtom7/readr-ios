import Foundation

struct Book: Identifiable, Equatable {
    let id: Int64
    var title: String
    var author: String
    var coverImagePath: String?
    var createdAt: Date

    init(id: Int64 = 0, title: String, author: String = "", coverImagePath: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.author = author
        self.coverImagePath = coverImagePath
        self.createdAt = createdAt
    }
}

extension Book {
    static let placeholder = Book(
        id: 0,
        title: "Unknown Book",
        author: "Unknown Author"
    )
}
