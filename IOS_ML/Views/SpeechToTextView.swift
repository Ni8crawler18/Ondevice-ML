import SwiftUI
import Speech
import AVFoundation

struct SpeechToTextView: View {
    @State private var isRecording = false
    @State private var recognizedText = "Press Start to begin speaking..."
    
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    
    @State private var request = SFSpeechAudioBufferRecognitionRequest()
    @State private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack(spacing: 20) {
            Text("Speech to Text")
                .font(.title2)
                .bold()
            
            TextEditor(text: .constant(recognizedText))
                .frame(height: 200)
                .disabled(true)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))
            
            Button(isRecording ? "Stop Recording" : "Start Recording") {
                if isRecording {
                    stopTranscribing()
                } else {
                    startTranscribing()
                }
                isRecording.toggle()
            }
            .buttonStyle(MainButton(color: .red))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Speech to Text")
        .onAppear {
            requestPermission()
        }
    }
    
    func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition permission denied.")
            }
        }
    }
    
    func startTranscribing() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        node.removeTap(onBus: 0) // Ensure no previous taps
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
            return
        }
        
        recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            } else if let error = error {
                print("Recognition error: \(error.localizedDescription)")
            }
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

