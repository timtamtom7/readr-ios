import SwiftUI

struct BookCard: View {
    let book: Book
    let quoteCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover / Placeholder
            coverView
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            // Title
            Text(book.title)
                .font(.system(.subheadline, design: .default, weight: .semibold))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(2)

            // Author
            if !book.author.isEmpty {
                Text(book.author)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .lineLimit(1)
            }

            // Quote count
            HStack(spacing: 4) {
                Image(systemName: "quote.opening")
                    .font(.caption2)
                Text("\(quoteCount) quote\(quoteCount == 1 ? "" : "s")")
                    .font(.caption)
            }
            .foregroundStyle(DesignTokens.accent)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DesignTokens.surface)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
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
            // Placeholder cover
            ZStack {
                LinearGradient(
                    colors: [DesignTokens.bookPlaceholder, DesignTokens.bookPlaceholder.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 36))
                        .foregroundStyle(DesignTokens.accent.opacity(0.6))

                    Text(book.title.prefix(2).uppercased())
                        .font(.system(.title, design: .serif, weight: .bold))
                        .foregroundStyle(DesignTokens.textPrimary.opacity(0.4))
                }
            }
        }
    }
}

#Preview {
    BookCard(
        book: Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald"),
        quoteCount: 3
    )
    .padding()
    .background(DesignTokens.bgLight)
}
