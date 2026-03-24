import Foundation
import SwiftUI
import AVFoundation

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var croppedImage: UIImage?
    @Published var recognizedText: String = ""
    @Published var selectedQuoteText: String = ""
    @Published var bookTitle: String = ""
    @Published var bookAuthor: String = ""
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var detectedRectangle: CGRect?

    // Crop corners (normalized 0-1 coordinates)
    @Published var topLeft: CGPoint = CGPoint(x: 0.1, y: 0.1)
    @Published var topRight: CGPoint = CGPoint(x: 0.9, y: 0.1)
    @Published var bottomLeft: CGPoint = CGPoint(x: 0.1, y: 0.9)
    @Published var bottomRight: CGPoint = CGPoint(x: 0.9, y: 0.9)

    private let ocrService = OCRService.shared
    private let db = DatabaseService.shared

    var step: CaptureStep = .camera

    enum CaptureStep {
        case camera
        case crop
        case quoteSelection
    }

    func capturePhoto(_ image: UIImage) {
        capturedImage = image
        step = .crop
    }

    func processCroppedImage() async {
        guard let image = croppedImage else { return }
        isProcessing = true
        errorMessage = nil

        do {
            recognizedText = try await ocrService.recognizeText(in: image)
            if recognizedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "No text detected. Try again with better lighting and a clearer image."
                isProcessing = false
                return
            }
            step = .quoteSelection
        } catch {
            errorMessage = "Text recognition failed. The page may be too blurry or poorly lit."
        }

        isProcessing = false
    }

    func detectPageBoundary() async {
        guard let image = capturedImage else { return }

        do {
            if let rect = try await ocrService.detectPageBoundary(in: image) {
                detectedRectangle = rect
                // Update crop corners based on detected rectangle
                topLeft = CGPoint(x: rect.minX, y: 1 - rect.maxY)
                topRight = CGPoint(x: rect.maxX, y: 1 - rect.maxY)
                bottomLeft = CGPoint(x: rect.minX, y: 1 - rect.minY)
                bottomRight = CGPoint(x: rect.maxX, y: 1 - rect.minY)
            }
        } catch {
            // Use default corners if detection fails
        }
    }

    func reset() {
        capturedImage = nil
        croppedImage = nil
        recognizedText = ""
        selectedQuoteText = ""
        bookTitle = ""
        bookAuthor = ""
        detectedRectangle = nil
        topLeft = CGPoint(x: 0.1, y: 0.1)
        topRight = CGPoint(x: 0.9, y: 0.1)
        bottomLeft = CGPoint(x: 0.1, y: 0.9)
        bottomRight = CGPoint(x: 0.9, y: 0.9)
        step = .camera
        isProcessing = false
        errorMessage = nil
    }

    func saveQuote(for book: Book?, libraryVM: LibraryViewModel) {
        let finalBook: Book
        if let existingBook = book {
            finalBook = existingBook
        } else {
            finalBook = Book(title: bookTitle.isEmpty ? "Unknown Book" : bookTitle, author: bookAuthor)
        }

        libraryVM.addBook(finalBook, quoteText: selectedQuoteText, pageImage: croppedImage)
    }
}
