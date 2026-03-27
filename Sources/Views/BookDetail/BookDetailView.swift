import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject var libraryVM: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var quotes: [Quote] = []
    @State private var selectedQuote: Quote?
    @State private var noteCount: Int = 0

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

                        // Notes section
                        notesSection

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
                        Theme.Haptics.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .accessibilityLabel("Close")
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            Theme.Haptics.warning()
                            libraryVM.deleteBook(book)
                            dismiss()
                        } label: {
                            Label("Delete Book", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                    .accessibilityLabel("More options")
                }
            }
            .sheet(item: $selectedQuote) { quote in
                QuoteDetailView(quote: quote)
            }
        }
        .onAppear {
            loadQuotes()
            loadNoteCount()
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

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.primaryText)

                Spacer()

                NavigationLink {
                    BookNotesView(book: book)
                } label: {
                    HStack(spacing: 4) {
                        if noteCount > 0 {
                            Text("\(noteCount)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(DesignTokens.accent)
                                .clipShape(Capsule())
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }

            NavigationLink {
                BookNotesView(book: book)
            } label: {
                HStack {
                    Image(systemName: "note.text")
                        .font(.title3)
                        .foregroundStyle(DesignTokens.accent)
                        .frame(width: 44, height: 44)
                        .background(DesignTokens.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(noteCount > 0 ? "\(noteCount) note\(noteCount == 1 ? "" : "s")" : "No notes yet")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(DesignTokens.primaryText)
                        Text("Add personal notes and reflections")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))
                }
                .padding()
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
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

    private func loadNoteCount() {
        DispatchQueue.global(qos: .userInitiated).async {
            let notes = (try? DatabaseService.shared.fetchNotesForBook(bookIdValue: book.id)) ?? []
            DispatchQueue.main.async {
                noteCount = notes.count
            }
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
