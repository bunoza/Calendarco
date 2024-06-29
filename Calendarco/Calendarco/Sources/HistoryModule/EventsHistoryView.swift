import SwiftData
import SwiftUI

struct EventsHistoryView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.openURL) var openURL
    @Query(sort: \EventEntity.creationDate, order: .reverse) private var events: [EventEntity]
    @EnvironmentObject private var mainViewModel: MainViewModel
    
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
                    Section {
                        
                        Menu {
                            if let urlString = event.downloadURL, let url = URL(string: urlString) {
                                Button {
                                    openURL(url)
                                } label: {
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Add to my calendar")
                                    }
                                }
                            }
                            Button {
                                withAnimation {
                                    mainViewModel.importEvent(event)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.down.on.square")
                                    Text("Import and edit")
                                }
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.descriptionText)
                                    .font(.subheadline)
                                Text("Created on: \(event.creationDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                Text("Expires on: \(event.expirationDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                            }
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
            .environmentObject(MainViewModel())
    }
}
