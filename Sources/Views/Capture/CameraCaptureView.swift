import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @ObservedObject var viewModel: CaptureViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isFlashOn = false
    @State private var cameraPosition: AVCaptureDevice.Position = .back
    @State private var cameraAuthStatus: AVAuthorizationStatus = .notDetermined
    @State private var showPermissionDenied = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        Theme.Haptics.light()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Close camera")

                    Spacer()

                    Button {
                        Theme.Haptics.light()
                        isFlashOn.toggle()
                    } label: {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.title3)
                            .foregroundStyle(isFlashOn ? .yellow : .white)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(isFlashOn ? "Turn off flash" : "Turn on flash")
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Camera preview placeholder
                CameraPreviewView(
                    isFlashOn: isFlashOn,
                    onCapture: { image in
                        viewModel.capturePhoto(image)
                    },
                    cameraPosition: cameraPosition
                )
                .frame(maxWidth: .infinity)
                .frame(height: 500)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)

                Spacer()

                // Bottom controls
                VStack(spacing: 20) {
                    Text("Hold parallel to the page")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    HStack(spacing: 40) {
                        // Photo library button
                        Button {
                            Theme.Haptics.light()
                            // TODO: Photo picker
                        } label: {
                            Image(systemName: "photo.on.rectangle")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                        }
                        .accessibilityLabel("Choose from photo library")

                        // Capture button
                        Button {
                            // Capture is triggered from CameraPreviewView
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 72, height: 72)

                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .accessibilityLabel("Capture page")

                        // Flip camera
                        Button {
                            Theme.Haptics.medium()
                            cameraPosition = cameraPosition == .back ? .front : .back
                        } label: {
                            Image(systemName: "camera.rotate")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                        }
                        .accessibilityLabel("Flip camera")
                    }
                }
                .padding(.bottom, 40)
            }

            // Permission denied overlay
            if showPermissionDenied {
                ZStack {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea()

                    CameraPermissionDeniedView()
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .animation(.easeInOut, value: showPermissionDenied)
    }

    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraAuthStatus = status

        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        showPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDenied = true
        case .authorized:
            showPermissionDenied = false
        @unknown default:
            break
        }
    }
}

// MARK: - Camera Preview UIViewRepresentable
struct CameraPreviewView: UIViewControllerRepresentable {
    let isFlashOn: Bool
    let onCapture: (UIImage) -> Void
    let cameraPosition: AVCaptureDevice.Position

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.isFlashOn = isFlashOn
        controller.onCapture = onCapture
        controller.cameraPosition = cameraPosition
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.isFlashOn = isFlashOn
        uiViewController.cameraPosition = cameraPosition
        uiViewController.updateCamera()
    }
}

class CameraViewController: UIViewController {
    var isFlashOn = false
    var cameraPosition: AVCaptureDevice.Position = .back
    var onCapture: ((UIImage) -> Void)?

    private var captureSession: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureDelegate: PhotoCaptureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let camera = getCamera(position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }

        photoOutput = AVCapturePhotoOutput()
        if let output = photoOutput, captureSession?.canAddOutput(output) == true {
            captureSession?.addOutput(output)
        }

        guard let session = captureSession else { return }
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let layer = previewLayer { view.layer.addSublayer(layer) }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }

        // Add tap to capture
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCapture))
        view.addGestureRecognizer(tap)
    }

    func updateCamera() {
        captureSession?.beginConfiguration()

        // Remove existing inputs
        captureSession?.inputs.forEach { captureSession?.removeInput($0) }

        guard let camera = getCamera(position: cameraPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        if captureSession?.canAddInput(input) == true {
            captureSession?.addInput(input)
        }

        captureSession?.commitConfiguration()
    }

    private func getCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        return discoverySession.devices.first
    }

    @objc private func didTapCapture() {
        capturePhoto()
    }

    func capturePhoto() {
        guard let output = photoOutput else { return }

        let settings = AVCapturePhotoSettings()
        if isFlashOn {
            settings.flashMode = .on
        }

        captureDelegate = PhotoCaptureDelegate { [weak self] image in
            DispatchQueue.main.async {
                self?.onCapture?(image)
            }
        }

        guard let delegate = captureDelegate else { return }
        output.capturePhoto(with: settings, delegate: delegate)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    let completion: (UIImage) -> Void

    init(completion: @escaping (UIImage) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        completion(image)
    }
}

#Preview {
    CameraCaptureView(viewModel: CaptureViewModel())
}
