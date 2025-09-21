import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    let detector: ObjectDetector

    func makeCoordinator() -> Coordinator {
        Coordinator(detector: detector)
    }

    func makeUIView(context: Context) -> CameraPreviewView {
        let previewView = CameraPreviewView()
        context.coordinator.startSession(previewView: previewView)
        return previewView
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {}
}

// MARK: - Coordinator

class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let detector: ObjectDetector
    private let captureSession = AVCaptureSession()

    init(detector: ObjectDetector) {
        self.detector = detector
        super.init()
    }

    func startSession(previewView: CameraPreviewView) {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.inputs.isEmpty else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        captureSession.commitConfiguration()

        previewView.videoPreviewLayer.session = captureSession
        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        detector.startDetection(sampleBuffer: sampleBuffer)
    }
}

// MARK: - Camera Preview View

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
