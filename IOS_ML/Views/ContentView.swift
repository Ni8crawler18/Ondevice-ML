import SwiftUI

struct ContentView: View {
    @State private var showScanner = false
    @State private var showPhotoPicker = false
    @State private var showShareSheet = false

    @State private var scannedImage: UIImage?
    @State private var scannedText: String = ""
    @State private var tempFileURL: URL?

    @StateObject private var historyManager = ScanHistoryManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Neuron")
                    .font(.title)
                    .bold()

                if let image = scannedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .cornerRadius(12)
                }

                if scannedText.isEmpty {
                    Text("No text extracted yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    TextEditor(text: $scannedText)
                        .frame(height: 150)
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                }

                HStack(spacing: 12) {
                    Button("Scan Document") {
                        showScanner = true
                    }
                    .buttonStyle(MainButton(color: .blue))

                    Button("Pick Image") {
                        showPhotoPicker = true
                    }
                    .buttonStyle(MainButton(color: .orange))
                }

                Button("Share Text") {
                    shareTextAsFile()
                }
                .disabled(scannedText.isEmpty)
                .buttonStyle(MainButton(color: .green))

                // 🔊 New Buttons
                NavigationLink("Text to Speech") {
                    TextToSpeechView(text: scannedText)
                }
                .buttonStyle(MainButton(color: .purple))

                NavigationLink("Speech to Text") {
                    SpeechToTextView()
                }
                .buttonStyle(MainButton(color: .pink))
                
                NavigationLink("Object Detection") {
                    ObjectDetectionView()
                }
                .buttonStyle(MainButton(color: .gray))

                NavigationLink("View History") {
                    HistoryView(historyManager: historyManager)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pinaca's ML")
        }
        .sheet(isPresented: $showScanner) {
            DocumentScannerView { image, text in
                showScanner = false
                scannedImage = image
                scannedText = text
                historyManager.addEntry(image: image, text: text)
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker { image in
                showPhotoPicker = false
                guard let image = image else { return }
                scannedImage = image
                scannedText = "Processing..."

                OCR.performOCR(on: image) { text in
                    DispatchQueue.main.async {
                        scannedText = text
                        historyManager.addEntry(image: image, text: text)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            tempFileURL = nil
        }) {
            if let tempFileURL {
                ShareSheet(activityItems: [tempFileURL])
            }
        }
    }

    func shareTextAsFile() {
        let fileName = "ScannedText.txt"
        let fileManager = FileManager.default
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDir.appendingPathComponent(fileName)

        do {
            try scannedText.write(to: fileURL, atomically: true, encoding: .utf8)
            tempFileURL = fileURL
            showShareSheet = true
        } catch {
            print("Error writing file: \(error)")
        }
    }
}

struct MainButton: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
