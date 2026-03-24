import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = OnboardingState.hasCompleted

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingContainerView(hasCompleted: $hasCompletedOnboarding)
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(0)

            SavedQuotesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(DesignTokens.accent)
    }
}

// MARK: - Saved Quotes View
struct SavedQuotesView: View {
    @State private var quotes: [Quote] = []
    @State private var selectedQuote: Quote?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if quotes.isEmpty {
                    savedEmptyState
                } else {
                    quotesList
                }
            }
            .navigationTitle("Saved")
            .sheet(item: $selectedQuote) { quote in
                QuoteDetailView(quote: quote)
            }
        }
        .onAppear { loadQuotes() }
    }

    private var savedEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark")
                .font(.system(size: 56))
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))

            Text("No saved quotes yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Quotes you save will appear here. Scan a page from any book to get started.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }

    private var quotesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(quotes) { quote in
                    SavedQuoteRow(quote: quote)
                        .onTapGesture {
                            selectedQuote = quote
                        }
                }
            }
            .padding()
        }
        .refreshable { loadQuotes() }
    }

    private func loadQuotes() {
        do {
            // Load all quotes across all books, sorted by date
            let db = DatabaseService.shared
            var allQuotes: [Quote] = []
            let books = try db.fetchAllBooks()
            for book in books {
                let bookQuotes = try db.fetchQuotes(forBookId: book.id)
                allQuotes.append(contentsOf: bookQuotes)
            }
            quotes = allQuotes.sorted { $0.createdAt > $1.createdAt }
        } catch {
            // silent fail
        }
    }
}

// MARK: - Saved Quote Row
struct SavedQuoteRow: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\"\(quote.text)\"")
                .font(.system(.body, design: .serif))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack {
                Image(systemName: "book.closed")
                    .font(.caption2)
                Text(quote.createdAt, style: .date)
                    .font(.caption)
            }
            .foregroundStyle(DesignTokens.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.surface)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var showingPricing = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                List {
                    // Account section
                    Section {
                        Button {
                            showingPricing = true
                        } label: {
                            HStack {
                                settingIcon("crown.fill", color: DesignTokens.accent)
                                Text("Subscription")
                                    .foregroundStyle(DesignTokens.primaryText)
                                Spacer()
                                Text("Free")
                                    .font(.subheadline)
                                    .foregroundStyle(DesignTokens.secondaryText)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                        }

                        Button {
                            // Restore purchases
                        } label: {
                            HStack {
                                settingIcon("arrow.clockwise", color: DesignTokens.secondaryText)
                                Text("Restore Purchases")
                                    .foregroundStyle(DesignTokens.primaryText)
                            }
                        }
                    } header: {
                        Text("Account")
                    }

                    // Appearance
                    Section {
                        HStack {
                            settingIcon("paintbrush", color: DesignTokens.accent)
                            Text("Appearance")
                                .foregroundStyle(DesignTokens.primaryText)
                            Spacer()
                            Text("System")
                                .font(.subheadline)
                                .foregroundStyle(DesignTokens.secondaryText)
                        }
                    } header: {
                        Text("Appearance")
                    }

                    // Data
                    Section {
                        HStack {
                            settingIcon("icloud", color: DesignTokens.secondaryText)
                            Text("iCloud Sync")
                                .foregroundStyle(DesignTokens.primaryText)
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .tint(DesignTokens.accent)
                        }

                        HStack {
                            settingIcon("square.and.arrow.up", color: DesignTokens.secondaryText)
                            Text("Export All Data")
                                .foregroundStyle(DesignTokens.primaryText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.secondaryText)
                        }
                    } header: {
                        Text("Data")
                    }

                    // About
                    Section {
                        HStack {
                            settingIcon("info.circle", color: DesignTokens.secondaryText)
                            Text("Version")
                                .foregroundStyle(DesignTokens.primaryText)
                            Spacer()
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundStyle(DesignTokens.secondaryText)
                        }

                        Link(destination: URL(string: "https://readr.app/privacy")!) {
                            HStack {
                                settingIcon("hand.raised", color: DesignTokens.secondaryText)
                                Text("Privacy Policy")
                                    .foregroundStyle(DesignTokens.primaryText)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                        }

                        Link(destination: URL(string: "https://readr.app/support")!) {
                            HStack {
                                settingIcon("envelope", color: DesignTokens.secondaryText)
                                Text("Contact Support")
                                    .foregroundStyle(DesignTokens.primaryText)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                        }
                    } header: {
                        Text("About")
                    }

                    // Reset onboarding
                    Section {
                        Button {
                            OnboardingState.hasCompleted = false
                        } label: {
                            HStack {
                                settingIcon("arrow.counterclockwise", color: DesignTokens.secondaryText)
                                Text("Show Onboarding Again")
                                    .foregroundStyle(DesignTokens.primaryText)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPricing) {
                PricingView()
            }
        }
    }

    private func settingIcon(_ systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.body)
            .foregroundStyle(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    ContentView()
        .environmentObject(LibraryViewModel())
}
