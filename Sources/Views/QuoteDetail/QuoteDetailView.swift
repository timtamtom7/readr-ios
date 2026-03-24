import SwiftUI

struct QuoteDetailView: View {
    let quote: Quote
    @Environment(\.dismiss) private var dismiss

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
        }
    }
}

#Preview {
    QuoteDetailView(quote: Quote(
        id: 1,
        bookId: 1,
        text: "The only way to do great work is to love what you do.",
        createdAt: Date()
    ))
}
