import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var quotes: [Quote] = []
    @State private var selectedQuote: Quote?

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Book header
                        bookHeader

                        Divider()
                            .padding(.horizontal)

                        // Quotes section
                        quotesSection
                    }
                    .padding()
                }
            }
            .navigationTitle(book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            libraryVM.deleteBook(book)
                            dismiss()
                        } label: {
                            Label("Delete Book", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }
            .sheet(item: $selectedQuote) { quote in
                QuoteDetailView(quote: quote)
            }
        }
        .onAppear {
            loadQuotes()
        }
    }

    private var bookHeader: some View {
        HStack(spacing: 16) {
            // Cover
            coverView
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.primaryText)

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.secondaryText)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "quote.opening")
                        .font(.caption)
                    Text("\(quotes.count) quote\(quotes.count == 1 ? "" : "s")")
                        .font(.caption)
                }
                .foregroundStyle(DesignTokens.accent)
            }

            Spacer()
        }
        .padding()
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var coverView: some View {
        if let coverPath = book.coverImagePath,
           let imageData = DatabaseService.shared.loadImage(atPath: coverPath),
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            ZStack {
                LinearGradient(
                    colors: [DesignTokens.bookPlaceholder, DesignTokens.bookPlaceholder.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 28))
                        .foregroundStyle(DesignTokens.accent.opacity(0.6))

                    Text(book.title.prefix(2).uppercased())
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(DesignTokens.textPrimary.opacity(0.4))
                }
            }
        }
    }

    private var quotesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quotes")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            if quotes.isEmpty {
                Text("No quotes saved yet")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(quotes) { quote in
                    QuoteRow(quote: quote)
                        .onTapGesture {
                            selectedQuote = quote
                        }
                }
            }
        }
    }

    private func loadQuotes() {
        do {
            quotes = try DatabaseService.shared.fetchQuotes(forBookId: book.id)
        } catch {
            // Handle error
        }
    }
}

struct QuoteRow: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\"\(quote.text)\"")
                .font(.system(.body, design: .serif))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(4)
                .multilineTextAlignment(.leading)

            Text(quote.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(DesignTokens.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BookDetailView(book: Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald"))
        .environmentObject(LibraryViewModel())
}
