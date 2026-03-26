import Foundation
import Combine

final class ReadrR12R20Service: ObservableObject, @unchecked Sendable {
    static let shared = ReadrR12R20Service()
    
    @Published var publicCollections: [PublicCollection] = []
    @Published var citationExports: [CitationExport] = []
    @Published var academicIntegrations: [AcademicIntegration] = []
    @Published var currentTier: ReadrSubscriptionTier = .free
    @Published var crossPlatformDevices: [CrossPlatformDevice] = []
    @Published var awardSubmissions: [AwardSubmission] = []
    @Published var apiCredentials: ReadrAPI?
    
    private let userDefaults = UserDefaults.standard
    
    private init() { loadFromDisk() }
    
    func createPublicCollection(name: String, ownerID: String) -> PublicCollection {
        let collection = PublicCollection(name: name, ownerID: ownerID, isPublic: true)
        publicCollections.append(collection)
        saveToDisk()
        return collection
    }
    
    func exportCitation(noteID: UUID, style: CitationExport.CitationStyle, text: String) -> CitationExport {
        let citation = CitationExport(noteID: noteID, citationStyle: style, exportedText: text)
        citationExports.append(citation)
        saveToDisk()
        return citation
    }
    
    func connectAcademicIntegration(platform: AcademicIntegration.Platform) -> AcademicIntegration {
        let integration = AcademicIntegration(platform: platform, isEnabled: true)
        academicIntegrations.append(integration)
        saveToDisk()
        return integration
    }
    
    func subscribe(to tier: ReadrSubscriptionTier) async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        await MainActor.run { currentTier = tier; saveToDisk() }
        return true
    }
    
    private func saveToDisk() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(publicCollections) { userDefaults.set(data, forKey: "readr_collections") }
        if let data = try? encoder.encode(citationExports) { userDefaults.set(data, forKey: "readr_citations") }
        if let data = try? encoder.encode(academicIntegrations) { userDefaults.set(data, forKey: "readr_integrations") }
        if let data = try? encoder.encode(crossPlatformDevices) { userDefaults.set(data, forKey: "readr_devices") }
        if let data = try? encoder.encode(awardSubmissions) { userDefaults.set(data, forKey: "readr_awards") }
    }
    
    private func loadFromDisk() {
        let decoder = JSONDecoder()
        if let data = userDefaults.data(forKey: "readr_collections"),
           let decoded = try? decoder.decode([PublicCollection].self, from: data) { publicCollections = decoded }
        if let data = userDefaults.data(forKey: "readr_citations"),
           let decoded = try? decoder.decode([CitationExport].self, from: data) { citationExports = decoded }
        if let data = userDefaults.data(forKey: "readr_integrations"),
           let decoded = try? decoder.decode([AcademicIntegration].self, from: data) { academicIntegrations = decoded }
        if let data = userDefaults.data(forKey: "readr_devices"),
           let decoded = try? decoder.decode([CrossPlatformDevice].self, from: data) { crossPlatformDevices = decoded }
        if let data = userDefaults.data(forKey: "readr_awards"),
           let decoded = try? decoder.decode([AwardSubmission].self, from: data) { awardSubmissions = decoded }
    }
}
