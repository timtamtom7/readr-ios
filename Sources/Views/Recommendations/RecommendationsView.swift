import SwiftUI

// MARK: - Recommendations View
struct RecommendationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recommendations: [BookRecommendation] = []
    @State private var detectedGenres: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if recommendations.isEmpty {
                    emptyState
                } else {
                    recommendationsList
                }
            }
            .navigationTitle("For You")
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
                    .accessibilityLabel("Close recommendations")
                }
            }
        }
        .onAppear { loadRecommendations() }
    }

    private var recommendationsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Genre pills
                if !detectedGenres.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Based on your reading")
                            .font(.subheadline)
                            .foregroundStyle(DesignTokens.secondaryText)

                        FlowLayout(spacing: 8) {
                            ForEach(detectedGenres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(DesignTokens.accent)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(DesignTokens.accent.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Recommendations grid
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(recommendations) { rec in
                        RecommendationCard(recommendation: rec)
                    }
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "books.vertical")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            Text("Add books to get recommendations")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("We'll suggest books based on what you read.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }

    private func loadRecommendations() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let books = (try? DatabaseService.shared.fetchAllBooks()) ?? []
            let genres = RecommendationService.shared.detectGenres(for: books)
            let recs = RecommendationService.shared.getRecommendationsForBooks(books)

            DispatchQueue.main.async {
                detectedGenres = genres
                recommendations = recs
                isLoading = false
            }
        }
    }
}

// MARK: - Recommendation Card
struct RecommendationCard: View {
    let recommendation: BookRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Cover placeholder
            ZStack {
                LinearGradient(
                    colors: [Color(hex: recommendation.coverColor), Color(hex: recommendation.coverColor).opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 6) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(recommendation.title.prefix(2).uppercased())
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .lineLimit(2)

                Text(recommendation.author)
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.secondaryText)

                Text(recommendation.reason)
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.accent)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Recommendations Tab View
struct RecommendationsTabView: View {
    @State private var recommendations: [BookRecommendation] = []
    @State private var detectedGenres: [String] = []
    @State private var isLoading = true
    @State private var showingAll = false

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                } else if recommendations.isEmpty {
                    emptyState
                } else {
                    recommendationsContent
                }
            }
            .navigationTitle("Recommendations")
            .sheet(isPresented: $showingAll) {
                RecommendationsView()
            }
        }
        .onAppear { loadRecommendations() }
    }

    private var recommendationsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Based on your library")
                        .font(.subheadline)
                        .foregroundStyle(DesignTokens.secondaryText)

                    if !detectedGenres.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(detectedGenres, id: \.self) { genre in
                                Text(genre)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(DesignTokens.accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(DesignTokens.accent.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Recommendations horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(recommendations) { rec in
                            CompactRecommendationCard(recommendation: rec)
                                .frame(width: 160)
                        }
                    }
                    .padding(.horizontal)
                }

                // See all button
                Button {
                    showingAll = true
                } label: {
                    Text("See All Recommendations")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DesignTokens.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(DesignTokens.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DesignTokens.accent.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(DesignTokens.accent.opacity(0.5))
            }

            Text("Recommendations coming soon")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Add more books to your library to get personalized recommendations.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }

    private func loadRecommendations() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let books = (try? DatabaseService.shared.fetchAllBooks()) ?? []
            let genres = RecommendationService.shared.detectGenres(for: books)
            let recs = RecommendationService.shared.getRecommendationsForBooks(books)

            DispatchQueue.main.async {
                detectedGenres = genres
                recommendations = recs
                isLoading = false
            }
        }
    }
}

// MARK: - Compact Recommendation Card
struct CompactRecommendationCard: View {
    let recommendation: BookRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: recommendation.coverColor), Color(hex: recommendation.coverColor).opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.6))

                    Text(recommendation.title.prefix(2).uppercased())
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(recommendation.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryText)
                .lineLimit(1)

            Text(recommendation.author)
                .font(.caption2)
                .foregroundStyle(DesignTokens.secondaryText)
                .lineLimit(1)

            Text(recommendation.reason)
                .font(.caption2)
                .foregroundStyle(DesignTokens.accent)
                .lineLimit(2)
        }
        .padding(10)
        .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    RecommendationsTabView()
}
