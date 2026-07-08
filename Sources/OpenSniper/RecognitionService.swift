#if os(macOS)
import Foundation
import CoreGraphics
import Vision
import OpenSniperCore

enum RecognitionError: LocalizedError {
    case noTextFound
    case noBarcodeFound

    var errorDescription: String? {
        switch self {
        case .noTextFound:
            return "No recognizable text was found in the selected area."
        case .noBarcodeFound:
            return "No QR code or barcode was found in the selected area."
        }
    }
}

final class RecognitionService {
    private let preferences = PreferencesStore.shared

    func recognize(mode: CaptureMode, image: CGImage, completion: @escaping (Result<String, Error>) -> Void) {
        switch mode {
        case .text:
            recognizeText(image: image, completion: completion)
        case .barcode:
            recognizeBarcode(image: image, completion: completion)
        }
    }

    private func recognizeText(image: CGImage, completion: @escaping (Result<String, Error>) -> Void) {
        let request = VNRecognizeTextRequest { [preferences] request, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = self.textLines(from: observations)
            let processor = TextPostProcessor(joinsLinesIntoParagraphs: preferences.joinLines)
            let text = processor.normalize(lines: lines)

            DispatchQueue.main.async {
                if text.isEmpty {
                    completion(.failure(RecognitionError.noTextFound))
                } else {
                    completion(.success(text))
                }
            }
        }

        request.recognitionLevel = preferences.recognitionLevel == "fast" ? .fast : .accurate
        request.usesLanguageCorrection = true

        let languages = preferences.recognitionLanguages
        if !languages.isEmpty {
            request.recognitionLanguages = languages
        }

        perform([request], image: image, completion: completion)
    }

    private func textLines(from observations: [VNRecognizedTextObservation]) -> [String] {
        observations
            .sorted { first, second in
                let verticalDistance = abs(first.boundingBox.midY - second.boundingBox.midY)

                if verticalDistance > 0.015 {
                    return first.boundingBox.midY > second.boundingBox.midY
                }

                return first.boundingBox.minX < second.boundingBox.minX
            }
            .compactMap { $0.topCandidates(1).first?.string }
    }

    private func recognizeBarcode(image: CGImage, completion: @escaping (Result<String, Error>) -> Void) {
        let request = VNDetectBarcodesRequest { request, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            let payloads = (request.results as? [VNBarcodeObservation] ?? [])
                .compactMap(\.payloadStringValue)
                .filter { !$0.isEmpty }

            DispatchQueue.main.async {
                if payloads.isEmpty {
                    completion(.failure(RecognitionError.noBarcodeFound))
                } else {
                    completion(.success(payloads.joined(separator: "\n")))
                }
            }
        }

        perform([request], image: image, completion: completion)
    }

    private func perform(_ requests: [VNRequest], image: CGImage, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                try handler.perform(requests)
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
#endif
