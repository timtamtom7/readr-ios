import SwiftUI
import UniformTypeIdentifiers

// MARK: - Export View
struct ExportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .pdf
    @State private var selectedCitationStyle: CitationStyle = .apa
    @State private var isExporting = false
    @State private var exportedFileURL: URL?
    @State private var exportedText: String?
    @State private var showingShareSheet = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var allQuotesWithBooks: [(Quote, Book)] = []

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Format selector
                        formatSection

                        // Citation style (only for citations format)
                        if selectedFormat == .citations {
                            citationStyleSection
                        }

                        // Preview
                        previewSection

                        // Export button
                        exportButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Export Quotes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(DesignTokens.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(activityItems: [url])
                } else if let text = exportedText {
                    ShareSheet(activityItems: [text])
                }
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear { loadQuotes() }
    }

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Format")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryText)

            VStack(spacing: 8) {
                ForEach(ExportFormat.allCases) { format in
                    ExportFormatRow(
                        format: format,
                        isSelected: selectedFormat == format
                    )
                    .onTapGesture { selectedFormat = format }
                }
            }
        }
    }

    private var citationStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Citation Style")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryText)

            VStack(spacing: 8) {
                ForEach(CitationStyle.allCases) { style in
                    CitationStyleRow(
                        style: style,
                        isSelected: selectedCitationStyle == style
                    )
                    .onTapGesture { selectedCitationStyle = style }
                }
            }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Preview")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryText)

                Spacer()

                Text("\(allQuotesWithBooks.count) quote\(allQuotesWithBooks.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            }

            if allQuotesWithBooks.isEmpty {
                emptyPreviewState
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(allQuotesWithBooks.prefix(3).enumerated()), id: \.offset) { _, item in
                        let (quote, book) = item
                        previewCard(quote: quote, book: book)
                    }
                    if allQuotesWithBooks.count > 3 {
                        Text("+ \(allQuotesWithBooks.count - 3) more quotes")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                }
            }
        }
    }

    private func previewCard(quote: Quote, book: Book) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\"\(quote.text.prefix(100))\(quote.text.count > 100 ? "..." : "")\"")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(2)

            Text("\(book.title) — \(book.author.isEmpty ? "Unknown" : book.author)")
                .font(.caption2)
                .foregroundStyle(DesignTokens.secondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 10))
    }

    private var emptyPreviewState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.title)
                .foregroundStyle(DesignTokens.secondaryText.opacity(0.5))

            Text("No quotes to export")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
    }

    private var exportButton: some View {
        Button {
            performExport()
        } label: {
            HStack {
                if isExporting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: exportIcon)
                    Text(exportButtonText)
                }
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(allQuotesWithBooks.isEmpty ? DesignTokens.secondaryText : DesignTokens.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(allQuotesWithBooks.isEmpty || isExporting)
    }

    private var exportIcon: String {
        switch selectedFormat {
        case .pdf: return "doc.fill"
        case .readwise: return "square.and.arrow.up"
        case .notion: return "square.and.arrow.up"
        case .obsidian: return "folder"
        case .citations: return "quote.bubble"
        }
    }

    private var exportButtonText: String {
        switch selectedFormat {
        case .pdf: return "Export as PDF"
        case .readwise: return "Copy Readwise CSV"
        case .notion: return "Copy Notion Markdown"
        case .obsidian: return "Copy Obsidian Format"
        case .citations: return "Export \(selectedCitationStyle.rawValue) Citations"
        }
    }

    private func loadQuotes() {
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [(Quote, Book)] = []
            let books = (try? DatabaseService.shared.fetchAllBooks()) ?? []
            for book in books {
                let quotes = (try? DatabaseService.shared.fetchQuotes(forBookId: book.id)) ?? []
                for quote in quotes {
                    results.append((quote, book))
                }
            }
            DispatchQueue.main.async {
                allQuotesWithBooks = results
            }
        }
    }

    private func performExport() {
        guard !allQuotesWithBooks.isEmpty else { return }
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            var resultURL: URL?
            var resultText: String?

            switch selectedFormat {
            case .pdf:
                if let data = ExportService.shared.exportQuotesToPDF(quotes: allQuotesWithBooks) {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("Readr_Quotes_\(Date().formatted(date: .numeric, time: .omitted)).pdf")
                    do {
                        try data.write(to: tempURL)
                        resultURL = tempURL
                    } catch {
                        DispatchQueue.main.async {
                            isExporting = false
                            errorMessage = "Failed to save PDF."
                            showingError = true
                        }
                        return
                    }
                }

            case .readwise:
                resultText = ExportService.shared.exportToReadwiseCSV(quotes: allQuotesWithBooks)

            case .notion:
                resultText = ExportService.shared.exportToNotionMarkdown(quotes: allQuotesWithBooks)

            case .obsidian:
                var lines: [String] = []
                lines.append("# My Quotes — Readr Export")
                lines.append("")
                for (quote, book) in allQuotesWithBooks {
                    let dateStr = quote.createdAt.formatted(date: .long, time: .omitted)
                    lines.append("## \(book.title) — \(book.author.isEmpty ? "Unknown" : book.author)")
                    lines.append("")
                    lines.append("> \(quote.text)")
                    lines.append("")
                    lines.append("Captured: \(dateStr)")
                    lines.append("")
                    lines.append("---")
                    lines.append("")
                }
                resultText = lines.joined(separator: "\n")

            case .citations:
                resultText = ExportService.shared.exportAllCitations(quotes: allQuotesWithBooks, style: selectedCitationStyle)
            }

            DispatchQueue.main.async {
                isExporting = false
                exportedFileURL = resultURL
                exportedText = resultText
                if resultURL != nil || resultText != nil {
                    showingShareSheet = true
                } else {
                    errorMessage = "Export failed. Please try again."
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Export Format Row
struct ExportFormatRow: View {
    let format: ExportFormat
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isSelected ? DesignTokens.accent : DesignTokens.accent.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: formatIcon)
                    .font(.body)
                    .foregroundStyle(isSelected ? .white : DesignTokens.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(format.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DesignTokens.primaryText)

                Text(formatDescription)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.secondaryText)
            }

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? DesignTokens.accent : DesignTokens.secondaryText.opacity(0.4))
        }
        .padding(14)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? DesignTokens.accent.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    private var formatIcon: String {
        switch format {
        case .pdf: return "doc.fill"
        case .readwise: return "square.and.arrow.up"
        case .notion: return "list.bullet.rectangle"
        case .obsidian: return "folder"
        case .citations: return "quote.bubble"
        }
    }

    private var formatDescription: String {
        switch format {
        case .pdf: return "Formatted PDF book of all quotes"
        case .readwise: return "CSV for Readwise import"
        case .notion: return "Markdown for Notion"
        case .obsidian: return "Markdown notes for Obsidian vault"
        case .citations: return "Formatted academic citations"
        }
    }
}

// MARK: - Citation Style Row
struct CitationStyleRow: View {
    let style: CitationStyle
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(style.rawValue)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DesignTokens.primaryText)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? DesignTokens.accent : DesignTokens.secondaryText.opacity(0.4))
        }
        .padding(14)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ExportView()
}
