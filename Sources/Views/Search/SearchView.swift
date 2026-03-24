import SwiftUI

struct SearchView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedQuote: Quote?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(DesignTokens.secondaryText)

                        TextField("Search books and quotes...", text: $libraryVM.searchQuery)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit {
                                libraryVM.performSearch()
                            }

                        if !libraryVM.searchQuery.isEmpty {
                            Button {
                                libraryVM.clearSearch()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }
                        }
                    }
                    .padding(14)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
                    .padding()

                    Divider()

                    // Results
                    if libraryVM.isSearching {
                        Spacer()
                        ProgressView()
                            .tint(DesignTokens.accent)
                        Spacer()
                    } else if libraryVM.searchQuery.isEmpty {
                        searchPrompt
                    } else if libraryVM.searchResults.isEmpty {
                        noResultsState
                    } else {
                        searchResultsList
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        libraryVM.clearSearch()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }
            .sheet(item: $selectedQuote) { quote in
                QuoteDetailView(quote: quote)
            }
        }
        .onChange(of: libraryVM.searchQuery) { _, newValue in
            if newValue.count >= 2 {
                performSearchDebounced()
            } else if newValue.isEmpty {
                libraryVM.clearSearch()
            }
        }
    }

    private var searchPrompt: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.4))

            Text("Search your library")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Find quotes or books by typing a title, author, or any word from a quote.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var noResultsState: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text("No quotes found")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryText)

                Text("No results for \"\(libraryVM.searchQuery)\".\nTry different keywords or check your spelling.")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Quote results
                let quoteResults = libraryVM.searchResults.filter { $0.quote != nil }
                if !quoteResults.isEmpty {
                    Section {
                        ForEach(quoteResults) { result in
                            if let quote = result.quote {
                                SearchQuoteRow(bookTitle: result.book.title, quote: quote)
                                    .onTapGesture {
                                        selectedQuote = quote
                                    }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Quotes")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DesignTokens.secondaryText)
                            Spacer()
                            Text("\(quoteResults.count) result\(quoteResults.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.secondaryText.opacity(0.7))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                // Book results
                let bookResults = libraryVM.searchResults.filter { $0.quote == nil }
                if !bookResults.isEmpty {
                    Section {
                        ForEach(bookResults) { result in
                            SearchBookRow(book: result.book)
                        }
                    } header: {
                        HStack {
                            Text("Books")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(DesignTokens.secondaryText)
                            Spacer()
                            Text("\(bookResults.count) result\(bookResults.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.secondaryText.opacity(0.7))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    private func performSearchDebounced() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if libraryVM.searchQuery.count >= 2 {
                libraryVM.performSearch()
            }
        }
    }
}

// MARK: - Search Quote Row
struct SearchQuoteRow: View {
    let bookTitle: String
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.accent)
                Text(bookTitle)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
            }

            Text("\"\(quote.text)\"")
                .font(.system(.body, design: .serif))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Text(quote.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Search Book Row
struct SearchBookRow: View {
    let book: Book

    var body: some View {
        HStack(spacing: 12) {
            // Cover thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignTokens.bookPlaceholder)

                if let coverPath = book.coverImagePath,
                   let imageData = DatabaseService.shared.loadImage(atPath: coverPath),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: "book.closed")
                        .font(.title3)
                        .foregroundStyle(DesignTokens.accent.opacity(0.5))
                }
            }
            .frame(width: 50, height: 70)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .lineLimit(2)

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    SearchView()
        .environmentObject(LibraryViewModel())
}
