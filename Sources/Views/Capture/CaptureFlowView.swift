import SwiftUI

struct CaptureFlowView: View {
    @EnvironmentObject var libraryVM: LibraryViewModel
    @StateObject private var viewModel = CaptureViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch viewModel.step {
            case .camera:
                CameraCaptureView(viewModel: viewModel)
            case .crop:
                CropView(viewModel: viewModel)
            case .quoteSelection:
                QuoteSelectionView(viewModel: viewModel)
                    .environmentObject(libraryVM)
            }
        }
        .interactiveDismissDisabled(viewModel.step != .camera)
        .onChange(of: viewModel.step) { _, newValue in
            if newValue == .camera {
                // Dismiss when returning to camera from outside
            }
        }
    }
}

#Preview {
    CaptureFlowView()
        .environmentObject(LibraryViewModel())
}
