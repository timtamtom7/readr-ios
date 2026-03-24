import Foundation

// MARK: - App-wide UserDefaults Keys
enum AppStorageKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
}

// MARK: - Onboarding State (shared across app)
enum OnboardingState {
    static var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: AppStorageKeys.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: AppStorageKeys.hasCompletedOnboarding) }
    }
}
