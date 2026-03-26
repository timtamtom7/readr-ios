import Foundation

// MARK: - Readr R12-R20: Social Features, Citations, Academic Platform

struct PublicCollection: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ownerID: String
    var noteIDs: [UUID]
    var isPublic: Bool
    var description: String
    var followerCount: Int
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, ownerID: String, noteIDs: [UUID] = [], isPublic: Bool = false, description: String = "", followerCount: Int = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.ownerID = ownerID
        self.noteIDs = noteIDs
        self.isPublic = isPublic
        self.description = description
        self.followerCount = followerCount
        self.createdAt = createdAt
    }
}

struct CitationExport: Identifiable, Codable, Equatable {
    let id: UUID
    var noteID: UUID
    var citationStyle: CitationStyle
    var exportedText: String
    var createdAt: Date
    
    enum CitationStyle: String, Codable, CaseIterable {
        case apa = "APA"
        case mla = "MLA"
        case chicago = "Chicago"
        case harvard = "Harvard"
        case ieee = "IEEE"
        case bibtex = "BibTeX"
    }
    
    init(id: UUID = UUID(), noteID: UUID, citationStyle: CitationStyle, exportedText: String = "", createdAt: Date = Date()) {
        self.id = id
        self.noteID = noteID
        self.citationStyle = citationStyle
        self.exportedText = exportedText
        self.createdAt = createdAt
    }
}

struct AcademicIntegration: Identifiable, Codable, Equatable {
    let id: UUID
    var platform: Platform
    var isEnabled: Bool
    var config: [String: String]
    
    enum Platform: String, Codable {
        case zotero = "Zotero"
        case mendeley = "Mendeley"
        case endnote = "EndNote"
        case notero = "Notero"
        case readwise = "Readwise"
        case hypothes = "Hypothes"
    }
    
    init(id: UUID = UUID(), platform: Platform, isEnabled: Bool = false, config: [String: String] = [:]) {
        self.id = id
        self.platform = platform
        self.isEnabled = isEnabled
        self.config = config
    }
}

struct ReadrSubscriptionTier: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var displayName: String
    var monthlyPrice: Decimal
    var annualPrice: Decimal
    var lifetimePrice: Decimal
    var features: [String]
    var isMostPopular: Bool
    
    static let free = ReadrSubscriptionTier(id: UUID(), name: "free", displayName: "Free", monthlyPrice: 0, annualPrice: 0, lifetimePrice: 0, features: ["10 articles/month", "Basic notes", "Simple highlights"], isMostPopular: false)
    static let scholar = ReadrSubscriptionTier(id: UUID(), name: "scholar", displayName: "Scholar", monthlyPrice: 7.99, annualPrice: 79.99, lifetimePrice: 149, features: ["Unlimited articles", "Citation export", "Academic integrations", "Public collections"], isMostPopular: true)
    static let institution = ReadrSubscriptionTier(id: UUID(), name: "institution", displayName: "Institution", monthlyPrice: 19.99, annualPrice: 191.88, lifetimePrice: 0, features: ["Everything in Scholar", "Team library", "Admin controls", "SSO", "Priority support"], isMostPopular: false)
}

struct SupportedLocale: Identifiable, Codable, Equatable {
    let id: UUID
    var code: String
    var displayName: String
    
    static let supported: [SupportedLocale] = [
        SupportedLocale(id: UUID(), code: "en", displayName: "English"),
        SupportedLocale(id: UUID(), code: "de", displayName: "German"),
        SupportedLocale(id: UUID(), code: "fr", displayName: "French"),
        SupportedLocale(id: UUID(), code: "es", displayName: "Spanish"),
    ]
}

struct CrossPlatformDevice: Identifiable, Codable, Equatable {
    let id: UUID
    var deviceName: String
    var platform: Platform
    
    enum Platform: String, Codable { case ios, android, web }
    
    init(id: UUID = UUID(), deviceName: String, platform: Platform) {
        self.id = id
        self.deviceName = deviceName
        self.platform = platform
    }
}

struct AwardSubmission: Identifiable, Codable, Equatable {
    let id: UUID
    var awardName: String
    var category: String
    var status: Status
    
    enum Status: String, Codable { case draft, submitted, inReview, won, rejected }
    
    init(id: UUID = UUID(), awardName: String, category: String, status: Status = .draft) {
        self.id = id
        self.awardName = awardName
        self.category = category
        self.status = status
    }
}

struct ReadrAPI: Codable, Equatable {
    var clientID: String
    var tier: APITier
    
    enum APITier: String, Codable { case free, paid }
    
    init(clientID: String = UUID().uuidString, tier: APITier = .free) {
        self.clientID = clientID
        self.tier = tier
    }
}
