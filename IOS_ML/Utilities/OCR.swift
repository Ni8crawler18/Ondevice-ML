import UIKit
import Vision

struct OCR {
    static func performOCR(on image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                print("OCR error: \(error!.localizedDescription)")
                completion("")
                return
            }

            let text = (request.results as? [VNRecognizedTextObservation])?
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n") ?? ""

            completion(text)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "hi-IN", "ta-IN"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("OCR processing failed: \(error.localizedDescription)")
                completion("")
            }
        }
    }
}
