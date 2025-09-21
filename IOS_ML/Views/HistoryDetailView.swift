import SwiftUI

struct HistoryDetailView: View {
    let item: ScanHistoryItem
    let historyManager: ScanHistoryManager
    @State private var showDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image = UIImage(data: item.imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity)
                }

                Text("Extracted Text:")
                    .font(.headline)

                Text(item.text)
                    .font(.body)
                    .padding(.bottom)

                Button(action: {
                    SpeechManager.shared.speak(item.text)
                }) {
                    Text("Speak")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Entry")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Scan Detail")
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this entry?"),
                primaryButton: .destructive(Text("Delete")) {
                    historyManager.delete(item: item)
                },
                secondaryButton: .cancel()
            )
        }
    }
}
