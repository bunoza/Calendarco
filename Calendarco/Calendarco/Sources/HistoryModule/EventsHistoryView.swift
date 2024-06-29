import FirebaseStorage
import SwiftData
import SwiftUI

struct EventsHistoryView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.openURL) var openURL
    @Query(sort: \EventEntity.creationDate, order: .reverse) private var events: [EventEntity]
    @EnvironmentObject private var mainViewModel: MainViewModel

    private let manager: FirebaseManager = .shared

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        NavigationView {
            Group {
                if events.isEmpty {
                    VStack {
                        Text("No events yet")
                            .font(.headline)
                    }
                } else {
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
                                        .disabled(event.expirationDate < Date())
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
                                        if !event.fileName.isEmpty {
                                            Text("\(event.fileName)")
                                                .font(.headline)
                                        }
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
                }
            }
            .navigationTitle("Events History")
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let event = events[index]
            manager.deleteFileFromFirebaseStorage(downloadURL: event.downloadURL) { success in
                if success {
                    context.delete(event)
                    try? context.save()
                } else {
                    print("Failed to delete the file from Firebase Storage")
                }
            }
        }
    }
}
