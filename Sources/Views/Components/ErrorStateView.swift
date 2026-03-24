import SwiftUI

// MARK: - Error Types
enum AppError: Identifiable, Equatable {
    case cameraPermissionDenied
    case ocrFailed(underlying: String?)
    case storageFull
    case unknown(message: String)

    var id: String {
        switch self {
        case .cameraPermissionDenied: return "camera"
        case .ocrFailed: return "ocr"
        case .storageFull: return "storage"
        case .unknown: return "unknown"
        }
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let error: AppError
    let retryAction: (() -> Void)?

    init(error: AppError, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            errorIcon
                .font(.system(size: 56))
                .foregroundStyle(errorAccentColor)

            VStack(spacing: 12) {
                Text(errorTitle)
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text(errorMessage)
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let retry = retryAction {
                Button(action: retry) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(errorAccentColor)
                    .clipShape(Capsule())
                }
                .padding(.top, 8)
            }

            if showsSettingsLink {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.subheadline)
                        .foregroundStyle(errorAccentColor)
                }
            }

            Spacer()
        }
        .padding()
    }

    private var errorIcon: Image {
        switch error {
        case .cameraPermissionDenied:
            return Image(systemName: "camera.fill")
        case .ocrFailed:
            return Image(systemName: "doc.text.magnifyingglass")
        case .storageFull:
            return Image(systemName: "externaldrive.fill")
        case .unknown:
            return Image(systemName: "exclamationmark.triangle.fill")
        }
    }

    private var errorAccentColor: Color {
        switch error {
        case .cameraPermissionDenied: return Color(hex: "c87b4f")
        case .ocrFailed: return Color(hex: "b07b4f")
        case .storageFull: return Color(hex: "c85f5f")
        case .unknown: return DesignTokens.secondaryText
        }
    }

    private var errorTitle: String {
        switch error {
        case .cameraPermissionDenied:
            return "Camera access needed"
        case .ocrFailed:
            return "Couldn't read the page"
        case .storageFull:
            return "Storage is full"
        case .unknown(let message):
            return message.isEmpty ? "Something went wrong" : message
        }
    }

    private var errorMessage: String {
        switch error {
        case .cameraPermissionDenied:
            return "Readr needs camera access to scan book pages. Tap \"Open Settings\" to grant permission in your device settings."
        case .ocrFailed:
            return "The text on this page couldn't be recognized. Try moving to better light, holding the phone steady, and making sure the page is flat."
        case .storageFull:
            return "Your device is out of storage space. Free up some room to continue saving quotes — try deleting unused apps or offloading photos."
        case .unknown:
            return "We ran into an unexpected problem. Please try again, or restart the app if the issue persists."
        }
    }

    private var showsSettingsLink: Bool {
        switch error {
        case .cameraPermissionDenied: return true
        default: return false
        }
    }
}

// MARK: - Empty State View (Library)
struct EmptyLibraryView: View {
    let onScanTapped: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            // Illustration
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Image(systemName: "books.vertical")
                    .font(.system(size: 52))
                    .foregroundStyle(DesignTokens.accent.opacity(0.7))
            }

            VStack(spacing: 12) {
                Text("Your library is waiting")
                    .font(.system(.title2, design: .serif, weight: .bold))
                    .foregroundStyle(DesignTokens.primaryText)

                Text("Every book you've loved has passages worth keeping. Scan your first page and start building a collection of the ideas that shaped you.")
                    .font(.body)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button(action: onScanTapped) {
                HStack(spacing: 10) {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan Your First Page")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(DesignTokens.accent)
                .clipShape(Capsule())
            }
            .padding(.top, 8)

            // Suggestion hint
            Text("Tip: Photograph a page you already have marked or highlighted")
                .font(.caption)
                .foregroundStyle(DesignTokens.secondaryText)
                .italic()
                .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

// MARK: - Empty Book Quotes View
struct EmptyQuotesView: View {
    let bookTitle: String
    let onScanTapped: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "faf3e8"), Color(hex: "f0e4d0")],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.accent.opacity(0.6))
            }

            VStack(spacing: 10) {
                Text("No quotes from \"\(bookTitle)\" yet")
                    .font(.headline)
                    .foregroundStyle(DesignTokens.primaryText)
                    .multilineTextAlignment(.center)

                Text("Flip through the pages you've already photographed. Tap a page to select a quote, or scan more pages from this book.")
                    .font(.subheadline)
                    .foregroundStyle(DesignTokens.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: onScanTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                    Text("Scan Another Page")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DesignTokens.accent)
            }
        }
        .padding(32)
    }
}

// MARK: - Camera Permission Denied Overlay
struct CameraPermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(DesignTokens.accent.opacity(0.6))

            Text("Camera access denied")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryText)

            Text("Please enable camera access in Settings to scan book pages.")
                .font(.subheadline)
                .foregroundStyle(DesignTokens.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(DesignTokens.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignTokens.surface)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

#Preview("Errors") {
    VStack {
        ErrorStateView(error: .cameraPermissionDenied) { }
        Divider()
        ErrorStateView(error: .ocrFailed(underlying: nil)) { }
        Divider()
        ErrorStateView(error: .storageFull) { }
    }
}

#Preview("Empty Library") {
    EmptyLibraryView(onScanTapped: { })
        .background(DesignTokens.background)
}

#Preview("Permission Denied") {
    CameraPermissionDeniedView()
        .background(Color.black.opacity(0.5))
}
