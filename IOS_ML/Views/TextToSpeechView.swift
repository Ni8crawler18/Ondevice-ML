import SwiftUI

struct TextToSpeechView: View {
    @State private var text: String
    @StateObject private var viewModel = SpeechViewModel()

    init(text: String) {
        _text = State(initialValue: text)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Text to Speech")
                .font(.headline)

            TextEditor(text: $text)
                .frame(height: 200)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))

            Button(action: {
                if viewModel.isSpeaking {
                    viewModel.togglePause()
                } else {
                    viewModel.speak(text)
                }
            }) {
                Text(viewModel.isSpeaking ? (viewModel.isPaused ? "Resume" : "Pause") : "Speak")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(MainButton(color: .blue))

            Spacer()
        }
        .padding()
        .onDisappear {
            viewModel.stop()
        }
    }
}

