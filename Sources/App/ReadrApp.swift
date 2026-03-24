import SwiftUI

@main
struct ReadrApp: App {
    @StateObject private var libraryViewModel = LibraryViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(libraryViewModel)
        }
    }
}
