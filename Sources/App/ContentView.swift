import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = OnboardingState.hasCompleted

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                AdaptiveContentView()
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

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(1)

            SavedQuotesView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tint(DesignTokens.accent)
    }
}

// MARK: - Discover View
struct DiscoverView: View {
    @State private var showingRandomQuote = false
    @State private var showingCollections = false
    @State private var showingTags = false
    @State private var showingRecommendations = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Recommendations
                        DiscoverCard(
                            icon: "sparkles",
                            title: "For You",
                            subtitle: "Book recommendations based on your library",
                            color: DesignTokens.accent
                        ) {
                            showingRecommendations = true
                        }

                        // Random Quote Card
                        DiscoverCard(
                            icon: "quote.bubble",
                            title: "Quote of the Day",
                            subtitle: "A random quote from your library",
                            color: DesignTokens.accent
                        ) {
                            showingRandomQuote = true
                        }

                        // Tags
                        DiscoverCard(
                            icon: "tag.fill",
                            title: "Tags",
                            subtitle: "Organize and filter quotes",
                            color: Color(hex: "7b6b8a")
                        ) {
                            showingTags = true
                        }

                        // Collections
                        DiscoverCard(
                            icon: "books.vertical.fill",
                            title: "Collections",
                            subtitle: "Organize books into shelves",
                            color: Color(hex: "7b6b8a")
                        ) {
                            showingCollections = true
                        }

                        // Search
                        NavigationLink {
                            SearchView()
                                .environmentObject(LibraryViewModel())
                        } label: {
                            DiscoverCard(
                                icon: "magnifyingglass",
                                title: "Search",
                                subtitle: "Find quotes and books",
                                color: Color(hex: "5a7a6a"),
                                isNavigation: true
                            ) { }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Discover")
            .sheet(isPresented: $showingRandomQuote) {
                RandomQuoteView()
            }
            .sheet(isPresented: $showingCollections) {
                CollectionsView()
                    .environmentObject(LibraryViewModel())
            }
            .sheet(isPresented: $showingTags) {
                TagManagementView()
            }
            .sheet(isPresented: $showingRecommendations) {
                RecommendationsView()
            }
        }
    }
}

// MARK: - Discover Card
struct DiscoverCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var isNavigation: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(DesignTokens.primaryText)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText)
                }

                Spacer()

                if isNavigation {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
                }
            }
            .padding(20)
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Saved Quotes View
struct SavedQuotesView: View {
    @State private var quotes: [Quote] = []
    @State private var allQuotes: [Quote] = []
    @State private var selectedQuote: Quote?
    @State private var showingTagFilter = false
    @State private var activeTagIds: Set<Int64> = []
    @State private var showingTagManagement = false
    @State private var isFiltering = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if allQuotes.isEmpty {
                    savedEmptyState
                } else if quotes.isEmpty && isFiltering {
                    filteredEmptyState
                } else {
                    quotesList
                }
            }
            .navigationTitle("Saved")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingTagFilter = true
                        } label: {
                            Image(systemName: activeTagIds.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .font(.title3)
                                .foregroundStyle(activeTagIds.isEmpty ? DesignTokens.secondaryText : DesignTokens.accent)
                        }

                        Button {
                            showingTagManagement = true
                        } label: {
                            Image(systemName: "tag")
                                .font(.title3)
                                .foregroundStyle(DesignTokens.secondaryText)
                        }
                    }
                }
            }
            .sheet(item: $selectedQuote) { quote in
                QuoteDetailView(quote: quote)
            }
            .sheet(isPresented: $showingTagFilter) {
                TagFilterView { selectedIds in
                    applyTagFilter(selectedIds)
                }
            }
            .sheet(isPresented: $showingTagManagement) {
                TagManagementView()
            }
        }
        .onAppear { loadQuotes() }
    }

    private var savedEmptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "bookmark")
                    .font(.system(size: 48))
                    .foregroundStyle(DesignTokens.secondaryText.opacity(0.4))
            }

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

    private var filteredEmptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "tag")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.accent.opacity(0.4))
            }

            Text("No quotes with these tags")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Try selecting different tags or clear the filter.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                clearTagFilter()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Clear Filter")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.accent)
            }
        }
        .padding()
    }

    private var quotesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if isFiltering {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .foregroundStyle(DesignTokens.accent)
                        Text("Filtered by tags")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                        Spacer()
                        Button("Clear") {
                            clearTagFilter()
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(DesignTokens.accent)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                }

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
            let db = DatabaseService.shared
            var loadedQuotes: [Quote] = []
            let books = try db.fetchAllBooks()
            for book in books {
                let bookQuotes = try db.fetchQuotes(forBookId: book.id)
                loadedQuotes.append(contentsOf: bookQuotes)
            }
            allQuotes = loadedQuotes.sorted { $0.createdAt > $1.createdAt }
            quotes = allQuotes
        } catch {
            // silent fail
        }
    }

    private func applyTagFilter(_ tagIds: Set<Int64>) {
        activeTagIds = tagIds
        isFiltering = !tagIds.isEmpty

        if tagIds.isEmpty {
            quotes = allQuotes
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var filtered: [Quote] = []
            for quote in allQuotes {
                do {
                    let quoteTagIds = try DatabaseService.shared.fetchTagsForQuote(quoteIdValue: quote.id).map { $0.id }
                    let quoteTagSet = Set(quoteTagIds)
                    if !quoteTagSet.isDisjoint(with: tagIds) {
                        filtered.append(quote)
                    }
                } catch {
                    continue
                }
            }
            DispatchQueue.main.async {
                quotes = filtered
            }
        }
    }

    private func clearTagFilter() {
        activeTagIds = []
        isFiltering = false
        quotes = allQuotes
    }
}

// MARK: - Saved Quote Row
struct SavedQuoteRow: View {
    let quote: Quote
    @State private var showingQuoteCard = false
    @State private var quoteTags: [Tag] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("\"\(quote.text)\"")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(DesignTokens.primaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button {
                    showingQuoteCard = true
                } label: {
                    Image(systemName: "square.on.square")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.accent.opacity(0.7))
                        .frame(width: 28, height: 28)
                        .background(DesignTokens.accent.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            // Tags
            if !quoteTags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(quoteTags.prefix(3)) { tag in
                        TagPillView(tag: tag)
                    }
                    if quoteTags.count > 3 {
                        Text("+\(quoteTags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }

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
        .sheet(isPresented: $showingQuoteCard) {
            let resolvedBook = (try? DatabaseService.shared.fetchBook(id: quote.bookId)) ?? Book(title: "Unknown Book")
            QuoteCardPreviewView(quote: quote, book: resolvedBook)
        }
        .onAppear {
            loadTags()
        }
    }

    private func loadTags() {
        DispatchQueue.global(qos: .userInitiated).async {
            let tags = (try? DatabaseService.shared.fetchTagsForQuote(quoteIdValue: quote.id)) ?? []
            DispatchQueue.main.async {
                quoteTags = tags
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var showingPricing = false
    @State private var showingExport = false

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

                        Button {
                            showingExport = true
                        } label: {
                            HStack {
                                settingIcon("square.and.arrow.up", color: DesignTokens.secondaryText)
                                Text("Export Quotes")
                                    .foregroundStyle(DesignTokens.primaryText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
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
            .sheet(isPresented: $showingExport) {
                ExportView()
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
