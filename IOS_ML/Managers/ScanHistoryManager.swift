import Foundation
import UIKit

struct ScanHistoryItem: Codable, Identifiable {
    var id = UUID()
    let text: String
    let imageData: Data
}

class ScanHistoryManager: ObservableObject {
    @Published var history: [ScanHistoryItem] = []

    private let storageKey = "scan_history"

    init() {
        loadHistory()
    }

    func addEntry(image: UIImage?, text: String) {
        guard let image = image,
              let data = image.jpegData(compressionQuality: 0.8) else { return }

        let item = ScanHistoryItem(text: text, imageData: data)
        history.insert(item, at: 0)
        saveHistory()
    }

    func saveHistory() {
        do {
            let encoded = try JSONEncoder().encode(history)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("Saving history failed: \(error)")
        }
    }
    
    func deleteEntries(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func delete(item: ScanHistoryItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            history = try JSONDecoder().decode([ScanHistoryItem].self, from: data)
        } catch {
            print("Loading history failed: \(error)")
        }
    }
}
