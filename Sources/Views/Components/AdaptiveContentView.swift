import SwiftUI

// MARK: - iPad Adaptive Layout
struct AdaptiveContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var libraryVM: LibraryViewModel
    @State private var selectedSidebarItem: SidebarItem? = .library
    @State private var selectedBook: Book?
    @State private var selectedQuote: Quote?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPad Layout with Sidebar
    private var iPadLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selectedItem: $selectedSidebarItem)
                .navigationTitle("Readr")
        } content: {
            contentColumn
        } detail: {
            detailColumn
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var contentColumn: some View {
        switch selectedSidebarItem {
        case .library:
            LibraryListView(
                selectedBook: $selectedBook,
                selectedQuote: $selectedQuote
            )
        case .discover:
            DiscoverView()
        case .saved:
            SavedQuotesView()
        case .community:
            CommunityView()
        case .settings:
            SettingsView()
        case .none:
            Color.clear
        }
    }

    @ViewBuilder
    private var detailColumn: some View {
        if let book = selectedBook {
            BookDetailView(book: book)
                .environmentObject(libraryVM)
        } else if let quote = selectedQuote {
            QuoteDetailView(quote: quote)
        } else {
            VStack(spacing: 16) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 64))
                    .foregroundStyle(DesignTokens.secondaryText.opacity(0.3))
                Text("Select a book to view details")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.background)
        }
    }

    // MARK: - iPhone Layout (Tab-based)
    private var iPhoneLayout: some View {
        MainTabView()
    }
}

// MARK: - Sidebar Items
enum SidebarItem: String, CaseIterable, Identifiable {
    case library = "Library"
    case discover = "Discover"
    case saved = "Saved"
    case community = "Community"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .library: return "books.vertical"
        case .discover: return "sparkles"
        case .saved: return "bookmark"
        case .community: return "globe"
        case .settings: return "gear"
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Binding var selectedItem: SidebarItem?
    @EnvironmentObject var libraryVM: LibraryViewModel

    var body: some View {
        List(selection: $selectedItem) {
            Section("Library") {
                ForEach([SidebarItem.library, .saved], id: \.id) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }

            Section("Explore") {
                Label(SidebarItem.discover.rawValue, systemImage: SidebarItem.discover.icon)
                    .tag(SidebarItem.discover)

                Label(SidebarItem.community.rawValue, systemImage: SidebarItem.community.icon)
                    .tag(SidebarItem.community)
            }

            Section {
                Label(SidebarItem.settings.rawValue, systemImage: SidebarItem.settings.icon)
                    .tag(SidebarItem.settings)
            }

            // Stats section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(libraryVM.books.count)")
                            .font(.headline)
                            .foregroundStyle(DesignTokens.accent)
                        Text("Books")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .padding(.vertical, 4)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(libraryVM.totalQuoteCount)")
                            .font(.headline)
                            .foregroundStyle(DesignTokens.accent)
                        Text("Quotes")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Your Library")
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - Library List View (for iPad detail column)
struct LibraryListView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Binding var selectedBook: Book?
    @Binding var selectedQuote: Quote?
    @State private var showingCapture = false
    @State private var showingCollections = false

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if libraryVM.isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if libraryVM.books.isEmpty {
                    emptyState
                } else {
                    bookGrid
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Theme.Haptics.medium()
                        showingCapture = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(DesignTokens.accent)
                    }
                    .accessibilityLabel("Capture new book")
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureFlowView()
                    .environmentObject(libraryVM)
            }
            .sheet(item: $selectedBook) { book in
                BookDetailView(book: book)
                    .environmentObject(libraryVM)
            }
        }
    }

    private var emptyState: some View {
        EmptyLibraryView {
            showingCapture = true
        }
    }

    private var bookGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(libraryVM.books) { book in
                    BookCard(
                        book: book,
                        quoteCount: libraryVM.quoteCounts[book.id] ?? 0
                    )
                    .onTapGesture {
                        selectedBook = book
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Community View
struct CommunityView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab selector
                    Picker("", selection: $selectedTab) {
                        Text("Feed").tag(0)
                        Text("Popular").tag(1)
                        Text("Share").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    TabView(selection: $selectedTab) {
                        CommunityFeedView()
                            .tag(0)

                        PopularQuotesView()
                            .tag(1)

                        ShareQuoteView()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Community")
        }
    }
}

// MARK: - Community Feed View
struct CommunityFeedView: View {
    @State private var feedQuotes: [CommunityQuote] = CommunityQuote.mockFeed
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(.top, 40)
            } else if feedQuotes.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(feedQuotes) { quote in
                        CommunityQuoteCard(quote: quote)
                    }
                }
                .padding()
            }
        }
        .refreshable {
            // Refresh feed
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 48))
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.4))

            Text("No community quotes yet")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Be the first to share a quote with the community!")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Popular Quotes View
struct PopularQuotesView: View {
    @State private var popularQuotes: [CommunityQuote] = CommunityQuote.mockPopular

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(popularQuotes.enumerated()), id: \.element.id) { index, quote in
                    HStack(spacing: 12) {
                        Text("#\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(DesignTokens.accent)
                            .frame(width: 32)

                        CommunityQuoteCard(quote: quote, compact: true)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Share Quote View
struct ShareQuoteView: View {
    @State private var quotes: [Quote] = []
    @State private var selectedQuote: Quote?
    @State private var showingShareConfirmation = false

    var body: some View {
        ScrollView {
            if quotes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 48))
                        .foregroundStyle(DesignTokens.secondaryText.opacity(0.4))

                    Text("Share a quote with the community")
                        .font(.headline)
                        .foregroundStyle(DesignTokens.primaryText)

                    Text("Select a saved quote to share it publicly")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    Text("Select a quote to share publicly")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ForEach(quotes) { quote in
                        ShareableQuoteRow(quote: quote) {
                            selectedQuote = quote
                            showingShareConfirmation = true
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear { loadQuotes() }
        .alert("Share Quote?", isPresented: $showingShareConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Share") {
                // Share the quote publicly
            }
        } message: {
            if let quote = selectedQuote {
                Text("This will make \"\(quote.text.prefix(50))...\" visible to all Readr community members.")
            }
        }
    }

    private func loadQuotes() {
        do {
            let db = DatabaseService.shared
            var allQuotes: [Quote] = []
            let books = try db.fetchAllBooks()
            for book in books {
                let bookQuotes = try db.fetchQuotes(forBookId: book.id)
                allQuotes.append(contentsOf: bookQuotes)
            }
            quotes = allQuotes
        } catch {
            // Handle error
        }
    }
}

// MARK: - Shareable Quote Row
struct ShareableQuoteRow: View {
    let quote: Quote
    let onShare: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(quote.text)\"")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(DesignTokens.primaryText)
                    .lineLimit(2)

                Text(quote.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            }

            Spacer()

            Button(action: onShare) {
                Image(systemName: "globe")
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(DesignTokens.accent)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Community Quote Card
struct CommunityQuoteCard: View {
    let quote: CommunityQuote
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.accent)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                    Text("\(quote.likeCount)")
                        .font(.caption)
                }
                .foregroundStyle(DesignTokens.secondaryText)
            }

            Text("\"\(quote.text)\"")
                .font(.system(compact ? .subheadline : .body, design: .serif))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(compact ? 2 : 4)
                .multilineTextAlignment(.leading)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(quote.bookTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignTokens.primaryText)
                    Text(quote.author)
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.secondaryText)
                }

                Spacer()

                Button {
                    Theme.Haptics.light()
                    // Like action
                } label: {
                    Image(systemName: "heart")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText)
                }
                .accessibilityLabel("Like")
            }
        }
        .padding()
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Community Quote Model
struct CommunityQuote: Identifiable {
    let id = UUID()
    let text: String
    let bookTitle: String
    let author: String
    let likeCount: Int
    let shareCount: Int

    static let mockFeed: [CommunityQuote] = [
        CommunityQuote(
            text: "The only way to do great work is to love what you do.",
            bookTitle: "Steve Jobs",
            author: "Walter Isaacson",
            likeCount: 42,
            shareCount: 8
        ),
        CommunityQuote(
            text: "We are what we repeatedly do. Excellence, then, is not an act, but a habit.",
            bookTitle: "Aristotle",
            author: "Will Durant",
            likeCount: 38,
            shareCount: 12
        ),
        CommunityQuote(
            text: "The mind is everything. What you think you become.",
            bookTitle: "The Buddha",
            author: "Buddha",
            likeCount: 56,
            shareCount: 15
        ),
    ]

    static let mockPopular: [CommunityQuote] = [
        CommunityQuote(
            text: "In the middle of difficulty lies opportunity.",
            bookTitle: "Albert Einstein",
            author: "Albert Einstein",
            likeCount: 127,
            shareCount: 34
        ),
        CommunityQuote(
            text: "It is not the strongest of the species that survives, nor the most intelligent, but the one most responsive to change.",
            bookTitle: "Charles Darwin",
            author: "Leon C. Megginson",
            likeCount: 98,
            shareCount: 28
        ),
        CommunityQuote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            bookTitle: "Eleanor Roosevelt",
            author: "Eleanor Roosevelt",
            likeCount: 89,
            shareCount: 22
        ),
    ]
}
