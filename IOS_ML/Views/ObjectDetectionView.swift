import SwiftUI

struct ObjectDetectionView: View {
    @StateObject private var detector = ObjectDetector()

    var body: some View {
        VStack {
            ZStack {
                CameraView(detector: detector)
                    .edgesIgnoringSafeArea(.horizontal)
                    .frame(height: 300)

                VStack {
                    Spacer()

                    Button(detector.isRunning ? "Stop Detection" : "Start Detection") {
                        detector.toggleDetection()
                    }
                    .buttonStyle(MainButton(color: detector.isRunning ? .red : .blue))
                    .padding(.bottom, 12)
                }
            }

            if !detector.observations.isEmpty {
                List(detector.observations, id: \.uuid) { obj in
                    let label = obj.labels.first?.identifier ?? "Unknown"
                    Text(label)
                }
                .frame(height: 200)
            } else {
                Text("No objects detected")
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("Object Detection")
    }
}
