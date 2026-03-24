import Foundation

struct Quote: Identifiable, Equatable {
    let id: Int64
    let bookId: Int64
    var text: String
    var pageImagePath: String?
    var createdAt: Date

    init(id: Int64 = 0, bookId: Int64, text: String, pageImagePath: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.bookId = bookId
        self.text = text
        self.pageImagePath = pageImagePath
        self.createdAt = createdAt
    }
}
