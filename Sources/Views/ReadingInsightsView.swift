import SwiftUI

/// R7: Deep Reading Insights view - AI-powered analysis and recommendations
struct ReadrReadingInsightsView: View {
    @StateObject private var insightsService = ReadrReadingInsightsService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if insightsService.isAnalyzing {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if insightsService.readingPatterns.isEmpty {
                    emptyState
                } else {
                    insightsContent
                }
            }
            .navigationTitle("Reading Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await insightsService.analyzeAll(books: [])
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(DesignTokens.accent)
                    }
                }
            }
            .task {
                if insightsService.readingPatterns.isEmpty {
                    await insightsService.analyzeAll(books: [])
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(DesignTokens.secondaryText)

            VStack(spacing: 6) {
                Text("No books to analyze")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(DesignTokens.primaryText)

                Text("Scan books to uncover\nreading insights.")
                    .font(.system(size: 14))
                    .foregroundColor(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await insightsService.analyzeAll(books: [])
                }
            } label: {
                Text("Analyze Now")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 44)
                    .background(DesignTokens.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 8)
        }
        .padding(40)
    }

    private var insightsContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                statsSection
                patternsSection
                recommendationsSection
            }
            .padding(.vertical, 16)
        }
    }

    private var statsSection: some View {
        VStack(spacing: 12) {
            ForEach(insightsService.insights) { insight in
                insightCard(insight)
            }
        }
        .padding(.horizontal, 16)
    }

    private func insightCard(_ insight: ReadrReadingInsightsService.ReadingInsight) -> some View {
        HStack(spacing: 16) {
            Image(systemName: insight.icon)
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.accent)
                .frame(width: 48, height: 48)
                .background(DesignTokens.accent.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.system(size: 13))
                    .foregroundColor(DesignTokens.secondaryText)

                Text(insight.value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(DesignTokens.primaryText)
            }

            Spacer()

            Text(insight.detail)
                .font(.system(size: 12))
                .foregroundColor(DesignTokens.secondaryText)
        }
        .padding(16)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Reading Patterns")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignTokens.primaryText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightsService.readingPatterns) { pattern in
                        patternCard(pattern)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func patternCard(_ pattern: ReadrReadingInsightsService.ReadingPattern) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: patternIcon(pattern.type))
                    .font(.system(size: 24))
                    .foregroundColor(DesignTokens.accent)
                Spacer()
            }

            Text(pattern.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignTokens.primaryText)

            Text(pattern.description)
                .font(.system(size: 13))
                .foregroundColor(DesignTokens.secondaryText)
                .lineLimit(3)
        }
        .frame(width: 160)
        .padding(16)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func patternIcon(_ type: ReadrReadingInsightsService.ReadingPattern.PatternType) -> String {
        switch type {
        case .voracious: return "star.fill"
        case .nightOwl: return "moon.fill"
        case .morningReader: return "sunrise.fill"
        case .quoteCollector: return "quote.bubble.fill"
        case .noteTaker: return "pencil.line"
        case .collector: return "archivebox.fill"
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for You")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(DesignTokens.primaryText)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                ForEach(insightsService.recommendations) { rec in
                    recommendationRow(rec)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func recommendationRow(_ rec: ReadrReadingInsightsService.BookRecommendation) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(DesignTokens.accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(rec.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DesignTokens.primaryText)

                Text(rec.author)
                    .font(.system(size: 13))
                    .foregroundColor(DesignTokens.secondaryText)

                HStack(spacing: 4) {
                    Text(rec.genre)
                        .font(.system(size: 11))
                    Text("•")
                    Text("\(rec.matchScore)% match")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignTokens.accent)
                }
                .foregroundColor(DesignTokens.secondaryText)
            }

            Spacer()
        }
        .padding(12)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
