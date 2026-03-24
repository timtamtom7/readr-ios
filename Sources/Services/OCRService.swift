import Foundation
import Vision
import UIKit

final class OCRService: Sendable {
    static let shared = OCRService()

    private init() {}

    nonisolated func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: recognizedText)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    nonisolated func detectPageBoundary(in image: UIImage) async throws -> CGRect? {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRectangleObservation],
                      let best = observations.first else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: best.boundingBox)
            }

            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 1.0
            request.minimumSize = 0.3
            request.maximumObservations = 1
            request.minimumConfidence = 0.5

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

enum OCRError: Error, LocalizedError {
    case invalidImage
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "The image could not be processed for text recognition."
        case .recognitionFailed:
            return "Text recognition failed."
        }
    }
}
