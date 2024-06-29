import SwiftUI
import SwiftData

struct EventsHistoryView: View {
    @Query(sort: \EventEntity.creationDate, order: .reverse) private var events: [EventEntity]
    @Environment(\.modelContext) private var context: ModelContext
    
    var body: some View {
        List {
            ForEach(events) { event in
                VStack(alignment: .leading) {
                    Text("File Name: \(event.title)")
                        .font(.headline)
                    Text("Number of Events: \(event.descriptionText)")
                        .font(.subheadline)
                    Text("Creation Date: \(event.creationDate, formatter: dateFormatter)")
                        .font(.subheadline)
                    Text("Expiration Date: \(event.expirationDate, formatter: dateFormatter)")
                        .font(.subheadline)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("Events History")
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let event = events[index]
            context.delete(event)
            try? context.save()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

struct EventsHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        EventsHistoryView()
    }
}
