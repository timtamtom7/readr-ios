import SwiftUI

/// R9: Anonymous community feed view
struct ReadrCommunityView: View {
    @StateObject private var communityService = ReadrCommunityService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.background
                    .ignoresSafeArea()

                if communityService.isLoading {
                    ProgressView()
                        .tint(DesignTokens.accent)
                        .scaleEffect(1.5)
                } else {
                    communityContent
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await communityService.loadPublicFeed()
            }
        }
    }

    private var communityContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(communityService.publicUpdates) { update in
                    updateCard(update)
                }
            }
            .padding(16)
        }
    }

    private func updateCard(_ update: ReadrCommunityService.PublicUpdate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 11))
                    Text(update.anonymousId)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(DesignTokens.secondaryText)

                Spacer()

                Text(timeAgo(update.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(DesignTokens.secondaryText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(update.bookTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.primaryText)

                Text("by \(update.author)")
                    .font(.system(size: 13))
                    .foregroundColor(DesignTokens.secondaryText)
            }

            HStack(spacing: 24) {
                VStack(spacing: 2) {
                    Text("\(update.pagesScanned)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignTokens.primaryText)
                    Text("Pages")
                        .font(.system(size: 10))
                        .foregroundColor(DesignTokens.secondaryText)
                }

                VStack(spacing: 2) {
                    Text("\(update.notesCount)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignTokens.primaryText)
                    Text("Notes")
                        .font(.system(size: 10))
                        .foregroundColor(DesignTokens.secondaryText)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12))
                    Text("\(update.likes)")
                        .font(.system(size: 12))
                }
                .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(DesignTokens.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
