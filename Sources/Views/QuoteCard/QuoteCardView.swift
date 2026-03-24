import SwiftUI
import PDFKit

// MARK: - Quote Card Template
enum QuoteCardTemplate: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case modern = "Modern"
    case editorial = "Editorial"
    case warm = "Warm"
    case midnight = "Midnight"
    case deepDark = "Deep Dark"

    var id: String { rawValue }

    var accentColor: Color {
        switch self {
        case .classic: return Color(hex: "c87b4f")
        case .modern: return Color(hex: "2c2c2c")
        case .editorial: return Color(hex: "8b4a4a")
        case .warm: return Color(hex: "d4943a")
        case .midnight: return Color(hex: "a78bfa")
        case .deepDark: return Color(hex: "f97316")
        }
    }

    var backgroundColor: Color {
        switch self {
        case .classic: return Color(hex: "faf8f5")
        case .modern: return Color(hex: "1a1a1a")
        case .editorial: return Color(hex: "f5f0e8")
        case .warm: return Color(hex: "fdf6ec")
        case .midnight: return Color(hex: "1e1b4b")
        case .deepDark: return Color(hex: "0c0a09")
        }
    }

    var textColor: Color {
        switch self {
        case .classic: return Color(hex: "2c2420")
        case .modern: return Color(hex: "f5f0eb")
        case .editorial: return Color(hex: "2c2420")
        case .warm: return Color(hex: "3d2b1f")
        case .midnight: return Color(hex: "f5f3ff")
        case .deepDark: return Color(hex: "fef3c7")
        }
    }

    var isDark: Bool {
        switch self {
        case .classic, .modern, .editorial, .warm: return false
        case .midnight, .deepDark: return true
        }
    }
}

// MARK: - Quote Card View
struct QuoteCardView: View {
    let quote: Quote
    let book: Book
    let template: QuoteCardTemplate
    let showShareButton: Bool

    @State private var showingShareSheet = false
    @State private var showingExportOptions = false
    @State private var renderedImage: UIImage?
    @State private var showingShareActivity = false
    @State private var showingShareError = false
    @State private var shareErrorMessage = ""
    @State private var showingCopiedToast = false

    init(quote: Quote, book: Book, template: QuoteCardTemplate = .classic, showShareButton: Bool = true) {
        self.quote = quote
        self.book = book
        self.template = template
        self.showShareButton = showShareButton
    }

    var body: some View {
        VStack(spacing: 0) {
            cardContent
        }
        .background(template.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .overlay(alignment: .topTrailing) {
            if showShareButton {
                Button {
                    showingExportOptions = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(template.textColor.opacity(0.6))
                        .padding(12)
                }
            }
        }
        .confirmationDialog("Share Quote Card", isPresented: $showingExportOptions) {
            Button("Share as Image") {
                shareAsImage()
            }
            Button("Share to Instagram") {
                shareToInstagram()
            }
            Button("Copy Text") {
                copyQuoteText()
            }
            Button("Export as PDF") {
                exportAsPDF()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingShareActivity) {
            if let image = renderedImage {
                ShareSheet(activityItems: [image])
            }
        }
        .alert("Share Failed", isPresented: $showingShareError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(shareErrorMessage)
        }
        .overlay(alignment: .bottom) {
            if showingCopiedToast {
                Text("Copied to clipboard")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.75), in: Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch template {
        case .classic:
            classicCard
        case .modern:
            modernCard
        case .editorial:
            editorialCard
        case .warm:
            warmCard
        case .midnight:
            midnightCard
        case .deepDark:
            deepDarkCard
        }
    }

    // MARK: - Classic Card
    private var classicCard: some View {
        VStack(spacing: 0) {
            Spacer()

            // Top ornament
            Image(systemName: "quote.opening")
                .font(.system(size: 48, design: .serif))
                .foregroundStyle(template.accentColor.opacity(0.3))
                .padding(.bottom, 8)

            Text(quote.text)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(template.textColor)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 40)

            // Attribution
            VStack(spacing: 6) {
                Rectangle()
                    .fill(template.accentColor)
                    .frame(width: 40, height: 2)

                Text("— \(book.title)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(template.textColor.opacity(0.8))

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(template.textColor.opacity(0.6))
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [template.backgroundColor, template.backgroundColor.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Modern Card
    private var modernCard: some View {
        VStack(spacing: 0) {
            HStack {
                Rectangle()
                    .fill(template.accentColor)
                    .frame(width: 3, height: 60)
                    .padding(.leading, 24)

                Spacer()
            }
            .padding(.top, 32)

            Text(quote.text)
                .font(.system(.title3, design: .default).weight(.medium))
                .foregroundStyle(template.textColor)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 40)

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(template.textColor.opacity(0.9))

                    if !book.author.isEmpty {
                        Text(book.author)
                            .font(.caption)
                            .foregroundStyle(template.textColor.opacity(0.5))
                    }
                }
                Spacer()

                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(template.accentColor.opacity(0.4))
                    .padding(.trailing, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Editorial Card
    private var editorialCard: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(template.accentColor)
                .frame(height: 4)

            Spacer()

            HStack(alignment: .top, spacing: 16) {
                Text(quote.text)
                    .font(.system(.title3, design: .serif))
                    .italic()
                    .foregroundStyle(template.textColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(10)
            }
            .padding(.horizontal, 40)

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(template.textColor.opacity(0.7))
                    .tracking(2)

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.caption2)
                        .foregroundStyle(template.textColor.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Warm Card
    private var warmCard: some View {
        VStack(spacing: 0) {
            // Decorative top
            HStack {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(template.accentColor.opacity(0.4))
                        .frame(width: 6, height: 6)
                }
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.top, 32)

            Spacer()

            ZStack {
                // Large decorative quote mark
                Text("\u{201C}")
                    .font(.system(size: 120, design: .serif))
                    .foregroundStyle(template.accentColor.opacity(0.08))
                    .offset(x: -20, y: -20)

                Text(quote.text)
                    .font(.system(.title3, design: .serif))
                    .foregroundStyle(template.textColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(10)
                    .padding(.horizontal, 48)
            }

            Spacer()

            // Bottom decoration
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { _ in
                        Rectangle()
                            .fill(template.accentColor.opacity(0.3))
                            .frame(width: 16, height: 1)
                    }
                }

                Text(book.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(template.textColor.opacity(0.7))

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.caption2)
                        .foregroundStyle(template.textColor.opacity(0.5))
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Midnight Card (Dark)
    private var midnightCard: some View {
        VStack(spacing: 0) {
            // Top gradient accent
            LinearGradient(
                colors: [template.accentColor.opacity(0.3), template.accentColor.opacity(0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 80)

            Spacer()

            Text(quote.text)
                .font(.system(.title3, design: .serif))
                .foregroundStyle(template.textColor)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)

            Spacer()

            VStack(spacing: 8) {
                Text("— \(book.title)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(template.textColor.opacity(0.8))

                if !book.author.isEmpty {
                    Text(book.author)
                        .font(.caption)
                        .foregroundStyle(template.textColor.opacity(0.5))
                }
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradient(
                colors: [Color(hex: "2d2a5e"), template.backgroundColor],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
        )
    }

    // MARK: - Deep Dark Card (Dark)
    private var deepDarkCard: some View {
        VStack(spacing: 0) {
            // Decorative left border
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [template.accentColor, template.accentColor.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .padding(.leading, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 32)

            Spacer()

            HStack(alignment: .top, spacing: 12) {
                Text("\u{201C}")
                    .font(.system(size: 60, design: .serif))
                    .foregroundStyle(template.accentColor.opacity(0.3))
                    .offset(y: -8)

                Text(quote.text)
                    .font(.system(.title3, design: .serif))
                    .fontWeight(.medium)
                    .foregroundStyle(template.textColor)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
            }
            .padding(.horizontal, 40)

            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(template.accentColor.opacity(0.8))
                        .tracking(1.5)

                    if !book.author.isEmpty {
                        Text(book.author)
                            .font(.caption2)
                            .foregroundStyle(template.textColor.opacity(0.4))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Export

    private func shareAsImage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let renderer = ImageRenderer(content: cardForExport)
            renderer.scale = 3.0
            if let image = renderer.uiImage {
                renderedImage = image
                showingShareActivity = true
            } else {
                shareErrorMessage = "Failed to render the quote card image. Please try again."
                showingShareError = true
            }
        }
    }

    private func shareToInstagram() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            // Render square for Instagram (1080x1080)
            let squareCard = cardContent
                .frame(width: 1080, height: 1080)

            let renderer = ImageRenderer(content: squareCard)
            renderer.scale = 3.0
            guard let image = renderer.uiImage,
                  let imageData = image.pngData() else {
                shareErrorMessage = "Failed to prepare image for Instagram. Please try again."
                showingShareError = true
                return
            }

            // Save to temp file for Instagram
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("quote_\(quote.id).png")
            do {
                try imageData.write(to: tempURL)
            } catch {
                shareErrorMessage = "Failed to save image. Please try again."
                showingShareError = true
                return
            }

            // Use Instagram URL scheme
            let instagramURL = URL(string: "instagram-stories://share?source_application=app.readr")!
            let photoLibraryURL = URL(string: "photos-redirect://")!

            if UIApplication.shared.canOpenURL(instagramURL) {
                // Copy image data to pasteboard for Instagram Stories
                let expiration = Date().addingTimeInterval(60 * 5)
                UIPasteboard.general.setItems([["public.png": imageData]], options: [.expirationDate: expiration])

                UIApplication.shared.open(instagramURL, options: [:], completionHandler: { success in
                    if !success {
                        shareErrorMessage = "Could not open Instagram. Please make sure Instagram is installed."
                        DispatchQueue.main.async {
                            showingShareError = true
                        }
                    }
                })
            } else if UIApplication.shared.canOpenURL(photoLibraryURL) {
                // Fallback: save to photo library
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                shareErrorMessage = "Image saved to your photo library. Open Instagram to share it."
                DispatchQueue.main.async {
                    showingShareError = true
                }
            } else {
                shareErrorMessage = "Instagram is not installed on this device."
                DispatchQueue.main.async {
                    showingShareError = true
                }
            }
        })
    }

    private func copyQuoteText() {
        let text = "\"\(quote.text)\"\n— \(book.title)\(book.author.isEmpty ? "" : ", \(book.author)")"
        UIPasteboard.general.string = text
        withAnimation(.easeInOut(duration: 0.2)) {
            showingCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingCopiedToast = false
            }
        }
    }

    private func exportAsPDF() {
        let pdfData = generatePDF()
        if let data = pdfData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("quote_\(quote.id).pdf")
            do {
                try data.write(to: tempURL)
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                }
            } catch {
                shareErrorMessage = "Failed to export PDF. Please try again."
                showingShareError = true
            }
        } else {
            shareErrorMessage = "Failed to generate PDF. Please try again."
            showingShareError = true
        }
    }

    private var cardForExport: some View {
        cardContent
            .frame(width: 600, height: 600)
    }

    private func generatePDF() -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)  // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()

            let cardHeight: CGFloat = 500
            let cardRect = CGRect(x: 0, y: (pageRect.height - cardHeight) / 2, width: pageRect.width, height: cardHeight)

            let cardRenderer = ImageRenderer(content: cardContent)
            cardRenderer.scale = 2.0
            if let uiImage = cardRenderer.uiImage {
                uiImage.draw(in: cardRect)
            }

            // Footer
            let footer = "\(book.title)\(book.author.isEmpty ? "" : " — \(book.author)")"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: paragraphStyle
            ]
            let footerRect = CGRect(x: 0, y: pageRect.height - 60, width: pageRect.width, height: 20)
            footer.draw(in: footerRect, withAttributes: attrs)
        }
    }
}

// MARK: - Quote Card Preview/Selector View
struct QuoteCardPreviewView: View {
    let quote: Quote
    let book: Book
    @State private var selectedTemplate: QuoteCardTemplate = .classic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Card preview
                    QuoteCardView(quote: quote, book: book, template: selectedTemplate)
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    // Template picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(QuoteCardTemplate.allCases) { template in
                                TemplateThumbnail(template: template, isSelected: selectedTemplate == template)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedTemplate = template
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 20)

                    // Template name
                    Text(selectedTemplate.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DesignTokens.primaryText)

                    Spacer()
                }
            }
            .navigationTitle("Quote Card")
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
            }
        }
    }
}

// MARK: - Template Thumbnail
struct TemplateThumbnail: View {
    let template: QuoteCardTemplate
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(template.backgroundColor)
                .frame(width: 60, height: 60)
                .overlay(
                    Text("\u{201C}")
                        .font(.system(size: 28, design: .serif))
                        .foregroundStyle(template.accentColor.opacity(0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? DesignTokens.accent : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text(template.rawValue)
                .font(.caption2)
                .foregroundStyle(isSelected ? DesignTokens.accent : DesignTokens.secondaryText)
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Random Quote View
struct RandomQuoteView: View {
    @State private var randomQuote: (Quote, Book)?
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showingCardPreview = false
    @State private var animateQuote = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if let (quote, book) = randomQuote {
                    VStack(spacing: 24) {
                        Spacer()

                        // Animated quote card
                        QuoteCardView(quote: quote, book: book, template: .classic, showShareButton: false)
                            .frame(height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
                            .padding(.horizontal, 32)
                            .scaleEffect(animateQuote ? 1 : 0.9)
                            .opacity(animateQuote ? 1 : 0)
                            .onAppear {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    animateQuote = true
                                }
                            }

                        // Actions
                        VStack(spacing: 12) {
                            Button {
                                showingCardPreview = true
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Create Quote Card")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(DesignTokens.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            Button {
                                animateQuote = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    loadRandomQuote()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "shuffle")
                                    Text("Show Another Quote")
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(DesignTokens.accent)
                            }
                        }
                        .padding(.horizontal, 32)

                        Spacer()
                    }
                } else if hasError {
                    errorState
                } else {
                    noQuotesState
                }
            }
            .navigationTitle("Quote of the Day")
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
            }
            .sheet(isPresented: $showingCardPreview) {
                if let (quote, book) = randomQuote {
                    QuoteCardPreviewView(quote: quote, book: book)
                }
            }
        }
        .onAppear {
            loadRandomQuote()
        }
    }

    private var noQuotesState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.accent.opacity(0.4))
            }

            Text("No quotes yet")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Scan your first book page to start collecting quotes.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }

    private var errorState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.red.opacity(0.5))
            }

            Text("Couldn't load quote")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text(errorMessage.isEmpty ? "Something went wrong. Please try again." : errorMessage)
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                loadRandomQuote()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(DesignTokens.accent)
                .clipShape(Capsule())
            }
        }
        .padding()
    }

    private func loadRandomQuote() {
        isLoading = true
        hasError = false
        errorMessage = ""

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let result = try DatabaseService.shared.fetchRandomQuote()
                DispatchQueue.main.async {
                    randomQuote = result
                    if result == nil {
                        // No quotes in database
                    }
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load a random quote. Please try again."
                    hasError = true
                    isLoading = false
                }
            }
        }
    }
}

#Preview("Classic") {
    QuoteCardView(
        quote: Quote(id: 1, bookId: 1, text: "The only way to do great work is to love what you do.", createdAt: Date()),
        book: Book(title: "Steve Jobs", author: "Walter Isaacson"),
        template: .classic
    )
    .frame(width: 400, height: 400)
}

#Preview("All Templates") {
    VStack {
        ForEach(QuoteCardTemplate.allCases) { template in
            QuoteCardView(
                quote: Quote(id: 1, bookId: 1, text: "The only way to do great work is to love what you do.", createdAt: Date()),
                book: Book(title: "Steve Jobs", author: "Walter Isaacson"),
                template: template,
                showShareButton: false
            )
            .frame(height: 300)
        }
    }
}
