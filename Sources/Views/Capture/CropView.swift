import SwiftUI

struct CropView: View {
    @ObservedObject var viewModel: CaptureViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DesignTokens.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Back") {
                        viewModel.step = .camera
                    }
                    .foregroundStyle(DesignTokens.primaryText)

                    Spacer()

                    Text("Crop")
                        .font(.headline)
                        .foregroundStyle(DesignTokens.primaryText)

                    Spacer()

                    Button("Done") {
                        Task {
                            await viewModel.processCroppedImage()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.accent)
                }
                .padding()
                .background(DesignTokens.surface)

                if let image = viewModel.capturedImage {
                    GeometryReader { geometry in
                        let size = geometry.size

                        ZStack {
                            // Image
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)

                            // Crop overlay with draggable corners
                            CropOverlayView(
                                topLeft: $viewModel.topLeft,
                                topRight: $viewModel.topRight,
                                bottomLeft: $viewModel.bottomLeft,
                                bottomRight: $viewModel.bottomRight,
                                imageSize: size
                            )
                        }
                        .frame(width: size.width, height: size.height)
                    }
                    .padding()
                }

                Spacer()

                // Retake button
                Button("Retake") {
                    viewModel.reset()
                }
                .foregroundStyle(DesignTokens.secondaryText)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            Task {
                await viewModel.detectPageBoundary()
            }
        }
    }
}

struct CropOverlayView: View {
    @Binding var topLeft: CGPoint
    @Binding var topRight: CGPoint
    @Binding var bottomLeft: CGPoint
    @Binding var bottomRight: CGPoint

    let imageSize: CGSize

    private let handleSize: CGFloat = 44
    private let lineWidth: CGFloat = 2

    var body: some View {
        ZStack {
            // Semi-transparent overlay outside crop area
            cropMask

            // Crop border
            cropBorder

            // Corner handles
            cornerHandle(for: $topLeft, color: DesignTokens.accent)
            cornerHandle(for: $topRight, color: DesignTokens.accent)
            cornerHandle(for: $bottomLeft, color: DesignTokens.accent)
            cornerHandle(for: $bottomRight, color: DesignTokens.accent)

            // Edge handles (midpoints)
            edgeHandle(at: midpoint(topLeft, topRight), color: DesignTokens.accent.opacity(0.6))
            edgeHandle(at: midpoint(bottomLeft, bottomRight), color: DesignTokens.accent.opacity(0.6))
            edgeHandle(at: midpoint(topLeft, bottomLeft), color: DesignTokens.accent.opacity(0.6))
            edgeHandle(at: midpoint(topRight, bottomRight), color: DesignTokens.accent.opacity(0.6))
        }
    }

    private var cropMask: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: imageSize.width, y: 0))
            path.addLine(to: CGPoint(x: imageSize.width, y: imageSize.height))
            path.addLine(to: CGPoint(x: 0, y: imageSize.height))
            path.closeSubpath()

            path.move(to: convertedPoint(topLeft))
            path.addLine(to: convertedPoint(topRight))
            path.addLine(to: convertedPoint(bottomRight))
            path.addLine(to: convertedPoint(bottomLeft))
            path.closeSubpath()
        }
        .fill(Color.black.opacity(0.4), style: FillStyle(eoFill: true))
    }

    private var cropBorder: some View {
        Path { path in
            path.move(to: convertedPoint(topLeft))
            path.addLine(to: convertedPoint(topRight))
            path.addLine(to: convertedPoint(bottomRight))
            path.addLine(to: convertedPoint(bottomLeft))
            path.closeSubpath()
        }
        .stroke(DesignTokens.accent, lineWidth: lineWidth)
    }

    private func convertedPoint(_ normalized: CGPoint) -> CGPoint {
        CGPoint(x: normalized.x * imageSize.width, y: normalized.y * imageSize.height)
    }

    private func cornerHandle(for point: Binding<CGPoint>, color: Color) -> some View {
        Circle()
            .fill(.white)
            .frame(width: handleSize, height: handleSize)
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .position(convertedPoint(point.wrappedValue))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newX = min(max(value.location.x / imageSize.width, 0), 1)
                        let newY = min(max(value.location.y / imageSize.height, 0), 1)
                        point.wrappedValue = CGPoint(x: newX, y: newY)
                    }
            )
    }

    private func edgeHandle(at point: CGPoint, color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 16, height: 16)
            .position(point)
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}

#Preview {
    CropView(viewModel: {
        let vm = CaptureViewModel()
        vm.capturedImage = UIImage(systemName: "doc.text")
        return vm
    }())
}
