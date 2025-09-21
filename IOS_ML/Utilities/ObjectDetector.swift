import Vision
import AVFoundation
import SwiftUI
import CoreML

class ObjectDetector: ObservableObject {
    @Published var observations: [VNRecognizedObjectObservation] = []
    private let sequenceHandler = VNSequenceRequestHandler()
    private(set) var isRunning = false

    private var visionModel: VNCoreMLModel?

    init() {
        loadModel()
    }

    private func loadModel() {
        do {
            let configuration = MLModelConfiguration()
            let model = try YOLOv3FP16(configuration: configuration).model
            visionModel = try VNCoreMLModel(for: model)
        } catch {
            print("Error loading YOLOv3FP16 model: \(error.localizedDescription)")
        }
    }

    func toggleDetection() {
        isRunning.toggle()
        if !isRunning {
            observations.removeAll()
        }
    }

    func startDetection(sampleBuffer: CMSampleBuffer) {
        guard isRunning,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let visionModel = visionModel else { return }

        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, _ in
            DispatchQueue.main.async {
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    self?.observations = results
                } else {
                    self?.observations = []
                }
            }
        }

        request.imageCropAndScaleOption = .scaleFill

        do {
            try sequenceHandler.perform([request], on: pixelBuffer)
        } catch {
            print("Object detection failed: \(error.localizedDescription)")
        }
    }
}

