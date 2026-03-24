import Foundation
import WidgetKit

// MARK: - App-wide UserDefaults Keys
enum AppStorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let widgetQuote = "widget_quote"
    static let widgetBookTitle = "widget_book_title"
    static let widgetAuthor = "widget_author"
}

// MARK: - Onboarding State (shared across app)
enum OnboardingState {
    static var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: AppStorageKeys.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: AppStorageKeys.hasCompletedOnboarding) }
    }
}

// MARK: - Widget Data Updater
enum WidgetDataUpdater {
    static func updateWidgetQuote(quote: String, bookTitle: String, author: String) {
        let defaults = UserDefaults(suiteName: "group.com.readr.app")
        defaults?.set(quote, forKey: AppStorageKeys.widgetQuote)
        defaults?.set(bookTitle, forKey: AppStorageKeys.widgetBookTitle)
        defaults?.set(author, forKey: AppStorageKeys.widgetAuthor)
        defaults?.synchronize()

        // Trigger widget reload
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    static func refreshWidget() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
