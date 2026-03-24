import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    let book: Book?
    @Environment(\.dismiss) private var dismiss
    @State private var showingQuoteCard = false
    @State private var resolvedBook: Book?

    init(quote: Quote, book: Book? = nil) {
        self.quote = quote
        self.book = book
        _resolvedBook = State(initialValue: book)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Original page image
                        if let pagePath = quote.pageImagePath,
                           let imageData = DatabaseService.shared.loadImage(atPath: pagePath),
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .onTapGesture {
                                    showingQuoteCard = true
                                }
                        }

                        // Quote text
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "quote.opening")
                                    .font(.title2)
                                    .foregroundStyle(DesignTokens.accent)

                                Spacer()

                                Text(quote.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(DesignTokens.secondaryText)
                            }

                            Text(quote.text)
                                .font(.system(.title3, design: .serif))
                                .foregroundStyle(DesignTokens.primaryText)
                                .textSelection(.enabled)

                            if let book = resolvedBook {
                                Divider()
                                    .padding(.vertical, 4)

                                HStack {
                                    Image(systemName: "book.closed")
                                        .font(.caption)
                                    Text(book.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    if !book.author.isEmpty {
                                        Text("— \(book.author)")
                                            .font(.caption)
                                            .foregroundStyle(DesignTokens.secondaryText)
                                    }
                                }
                                .foregroundStyle(DesignTokens.secondaryText)
                            }

                            // Create quote card button
                            Button {
                                showingQuoteCard = true
                            } label: {
                                HStack {
                                    Image(systemName: "square.on.square")
                                    Text("Create Quote Card")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(DesignTokens.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(DesignTokens.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .padding(.top, 8)

                            Divider()
                                .padding(.vertical, 4)

                            // Tags section
                            QuoteTagEditorView(quoteId: quote.id)

                            Spacer()
                        }
                        .padding()
                        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
            }
            .navigationTitle("Quote")
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
                    ShareLink(item: quote.text) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingQuoteCard) {
                QuoteCardPreviewView(quote: quote, book: resolvedBook ?? Book(title: "Unknown Book"))
            }
        }
        .onAppear {
            loadBook()
        }
    }

    private func loadBook() {
        guard resolvedBook == nil else { return }
        resolvedBook = (try? DatabaseService.shared.fetchBook(id: quote.bookId)) ?? Book(title: "Unknown Book")
    }
}

#Preview {
    QuoteDetailView(
        quote: Quote(
            id: 1,
            bookId: 1,
            text: "The only way to do great work is to love what you do.",
            createdAt: Date()
        ),
        book: Book(title: "Steve Jobs", author: "Walter Isaacson")
    )
}
