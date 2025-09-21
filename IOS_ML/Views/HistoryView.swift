import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: ScanHistoryManager

    var body: some View {
        List {
            ForEach(historyManager.history) { item in
                NavigationLink(destination: HistoryDetailView(item: item, historyManager: historyManager)) {
                    HStack {
                        if let image = UIImage(data: item.imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(6)
                        }
                        VStack(alignment: .leading) {
                            Text(item.text)
                                .lineLimit(2)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("History")
        .toolbar {
            EditButton()
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        historyManager.deleteEntries(at: offsets)
    }
}
