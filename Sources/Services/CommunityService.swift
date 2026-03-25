import Foundation

/// R9: Community and social features service
@MainActor
final class ReadrCommunityService: ObservableObject {
    static let shared = ReadrCommunityService()

    @Published private(set) var publicUpdates: [PublicUpdate] = []
    @Published private(set) var isLoading = false

    struct PublicUpdate: Identifiable, Codable {
        let id: UUID
        let anonymousId: String
        let bookTitle: String
        let author: String
        let pagesScanned: Int
        let notesCount: Int
        let timestamp: Date
        let likes: Int
    }

    private init() {}

    func loadPublicFeed() async {
        isLoading = true

        try? await Task.sleep(nanoseconds: 500_000_000)

        publicUpdates = [
            PublicUpdate(id: UUID(), anonymousId: "reader_x7k2", bookTitle: "The Midnight Library", author: "Matt Haig", pagesScanned: 45, notesCount: 3, timestamp: Date().addingTimeInterval(-3600), likes: 24),
            PublicUpdate(id: UUID(), anonymousId: "bookworm_m3p9", bookTitle: "Atomic Habits", author: "James Clear", pagesScanned: 30, notesCount: 5, timestamp: Date().addingTimeInterval(-7200), likes: 42),
            PublicUpdate(id: UUID(), anonymousId: "literary_fan_b5n1", bookTitle: "Project Hail Mary", author: "Andy Weir", pagesScanned: 60, notesCount: 2, timestamp: Date().addingTimeInterval(-10800), likes: 18),
            PublicUpdate(id: UUID(), anonymousId: "page_turner_k8r4", bookTitle: "Lessons in Chemistry", author: "Bonnie Garmus", pagesScanned: 25, notesCount: 4, timestamp: Date().addingTimeInterval(-14400), likes: 31),
            PublicUpdate(id: UUID(), anonymousId: "story_seeker_c2t7", bookTitle: "Tomorrow, and Tomorrow, and Tomorrow", author: "Gabrielle Zevin", pagesScanned: 50, notesCount: 6, timestamp: Date().addingTimeInterval(-18000), likes: 56)
        ]

        isLoading = false
    }
}
