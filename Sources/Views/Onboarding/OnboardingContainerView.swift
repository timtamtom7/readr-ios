import SwiftUI

// MARK: - Onboarding Storage
// Note: OnboardingState is defined in AppState.swift for shared access

// MARK: - Onboarding Container
struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @Binding var hasCompleted: Bool

    var body: some View {
        ZStack {
            DesignTokens.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? DesignTokens.accent : DesignTokens.secondaryText.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 24)

                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    OnboardingPage2()
                        .tag(1)
                    OnboardingPage3()
                        .tag(2)
                    OnboardingPage4(hasCompleted: $hasCompleted)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom navigation
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundStyle(DesignTokens.secondaryText)
                    }

                    Spacer()

                    if currentPage < 3 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.accent)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Page 1: Concept
struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Hero illustration
            OnboardingHeroIllustration(icon: .quote)
                .frame(width: 220, height: 220)

            VStack(spacing: 16) {
                Text("Every great quote\ndeserves a home")
                    .font(.system(.title, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text("You've dog-eared pages, scribbled in margins, and highlighted passages that moved you. Readr gives those moments a permanent place.")
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

// MARK: - Page 2: Capture
struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Camera illustration
            OnboardingCameraIllustration()
                .frame(width: 220, height: 220)

            VStack(spacing: 16) {
                Text("Capture any page")
                    .font(.system(.title, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text("Hold your phone over any book page. Readr automatically detects the page boundaries and extracts the text in seconds.")
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

// MARK: - Page 3: Library
struct OnboardingPage3: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Library illustration
            OnboardingLibraryIllustration()
                .frame(width: 220, height: 220)

            VStack(spacing: 16) {
                Text("Build your library")
                    .font(.system(.title, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text("Every quote you capture is organized by book. Flip through your collection — find that passage you loved in *Sapiens* or that poem you bookmarked years ago.")
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

// MARK: - Page 4: Start Scanning
struct OnboardingPage4: View {
    @Binding var hasCompleted: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Quote card illustration
            OnboardingQuoteCardIllustration()
                .frame(width: 220, height: 220)

            VStack(spacing: 16) {
                Text("Never lose a quote again")
                    .font(.system(.title, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text("The books you read leave marks on you. Let's make sure you remember them. Ready to scan your first page?")
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            Button {
                OnboardingState.hasCompleted = true
                hasCompleted = true
            } label: {
                Text("Start Scanning")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DesignTokens.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Onboarding Illustrations

enum OnboardingIcon {
    case quote
    case camera
    case library
    case card
}

struct OnboardingHeroIllustration: View {
    let icon: OnboardingIcon

    var body: some View {
        ZStack {
            // Warm paper background circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .shadow(color: Color(hex: "c87b4f").opacity(0.15), radius: 20, x: 0, y: 8)

            // SF Symbol composition for quote/book
            VStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 48, weight: .light, design: .serif))
                    .foregroundStyle(DesignTokens.accent)

                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(DesignTokens.textPrimary.opacity(0.6))
            }
        }
    }
}

struct OnboardingCameraIllustration: View {
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .shadow(color: Color(hex: "c87b4f").opacity(0.15), radius: 20, x: 0, y: 8)

            // Camera body
            ZStack {
                // Camera rectangle
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "3d3d3d"))
                    .frame(width: 130, height: 90)

                // Lens circle
                Circle()
                    .stroke(Color(hex: "c87b4f"), lineWidth: 3)
                    .frame(width: 50, height: 50)

                Circle()
                    .fill(Color(hex: "1a1a1a"))
                    .frame(width: 38, height: 38)

                Circle()
                    .fill(Color(hex: "c87b4f").opacity(0.3))
                    .frame(width: 20, height: 20)

                // Viewfinder corner brackets
                ForEach([(CGPoint(x: 110, y: 20), 1, 1),
                         (CGPoint(x: 20, y: 20), -1, 1),
                         (CGPoint(x: 20, y: 70), -1, -1),
                         (CGPoint(x: 110, y: 70), 1, -1)], id: \.0) { point, xDir, yDir in
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 10 * yDir))
                        path.addLine(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 10 * xDir, y: 0))
                    }
                    .stroke(DesignTokens.accent, lineWidth: 2)
                    .offset(x: point.x - 65, y: point.y - 45)
                }

                // Flash
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "c87b4f"))
                    .frame(width: 16, height: 8)
                    .offset(x: -40, y: -55)

                // Page being captured (below camera)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 70, height: 50)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    .offset(y: 70)

                // Lines on page
                VStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "d0d0d0"))
                            .frame(width: 50, height: 3)
                    }
                }
                .offset(y: 68)
            }
        }
    }
}

struct OnboardingLibraryIllustration: View {
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .shadow(color: Color(hex: "c87b4f").opacity(0.15), radius: 20, x: 0, y: 8)

            // Book spines
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(bookColor(for: index))
                            .frame(width: bookWidth(for: index), height: 90)

                        // Pages edge
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "e8e0d5"))
                            .frame(width: bookWidth(for: index) - 4, height: 4)
                            .offset(y: -1)
                    }
                }
            }

            // Open book on top
            Image(systemName: "book.closed.fill")
                .font(.system(size: 40))
                .foregroundStyle(DesignTokens.accent)
                .offset(y: -10)
        }
    }

    private func bookColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "8b7355"),
            Color(hex: "6b8e6b"),
            Color(hex: "9b7b6b"),
            Color(hex: "7b8b9b")
        ]
        return colors[index % colors.count]
    }

    private func bookWidth(for index: Int) -> CGFloat {
        let widths: [CGFloat] = [22, 18, 24, 20]
        return widths[index % widths.count]
    }
}

struct OnboardingQuoteCardIllustration: View {
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .shadow(color: Color(hex: "c87b4f").opacity(0.15), radius: 20, x: 0, y: 8)

            // Quote card with paper texture effect
            VStack(alignment: .leading, spacing: 12) {
                // Opening quote mark
                Image(systemName: "quote.opening")
                    .font(.system(size: 24, weight: .light, design: .serif))
                    .foregroundStyle(DesignTokens.accent.opacity(0.6))

                // Fake quote text
                Text("The only way to do\ngreat work is to love\nwhat you do.")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(DesignTokens.textPrimary.opacity(0.8))
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)

                // Book attribution
                HStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.caption2)
                    Text("Steve Jobs")
                        .font(.system(.caption2, design: .serif))
                        .italic()
                }
                .foregroundStyle(DesignTokens.secondaryText)
                .padding(.top, 4)
            }
            .padding(20)
            .frame(width: 170, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "fffdf8"),
                                Color(hex: "f8f2e8"),
                                Color(hex: "f0e8d8")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "e0d8c8"), lineWidth: 1)
            )
            .shadow(color: Color(hex: "a08060").opacity(0.2), radius: 12, x: 0, y: 6)

            // Small highlight badge
            Circle()
                .fill(DesignTokens.accent)
                .frame(width: 12, height: 12)
                .offset(x: 60, y: -55)
        }
    }
}

#Preview("Onboarding") {
    OnboardingContainerView(hasCompleted: .constant(false))
}
