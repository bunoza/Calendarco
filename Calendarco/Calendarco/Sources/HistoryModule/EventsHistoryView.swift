import SwiftData
import SwiftUI

struct EventsHistoryView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query(sort: \EventEntity.creationDate, order: .reverse) private var events: [EventEntity]

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(events) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.descriptionText)
                            .font(.subheadline)
                        Text("Created on: \(event.creationDate, formatter: dateFormatter)")
                            .font(.subheadline)
                        Text("Expires on: \(event.expirationDate, formatter: dateFormatter)")
                            .font(.subheadline)
                        if let urlString = event.downloadURL, let url = URL(string: urlString) {
                            Link("Open File", destination: url)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Events History")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let event = events[index]
            context.delete(event)
            try? context.save()
        }
    }
}

struct EventsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EventsHistoryView()
    }
}
