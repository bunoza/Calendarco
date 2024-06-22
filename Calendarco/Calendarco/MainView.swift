import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CalendarEventViewModel()
    @State private var tempFileURL: URL? = nil
    @State private var expandedSections: Set<UUID> = []

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    ForEach($viewModel.events) { $event in
                        let isExpanded = Binding<Bool>(
                            get: { expandedSections.contains(event.id) },
                            set: { newValue in
                                if newValue {
                                    expandedSections.insert(event.id)
                                } else {
                                    expandedSections.remove(event.id)
                                }
                            }
                        )

                        DisclosureGroup(isExpanded: isExpanded) {
                            TextField("Event Title", text: $event.title)
                                .onChange(of: event.title) { _ in
                                    handleEventChange()
                                }
                            DatePicker("Start Date", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.startDate) { _ in
                                    handleEventChange()
                                }
                            DatePicker("End Date", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.endDate) { _ in
                                    handleEventChange()
                                }
                        } label: {
                            Text(event.title.isEmpty ? "Event" : event.title)
                        }
                    }
                    .onDelete(perform: deleteEvent)

                    Section {} footer: {
                        Button {
                            withAnimation {
                                viewModel.addEvent()
                                handleEventChange()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Add Event")
                                Spacer()
                            }
                        }
                    }
                }
                .onAppear {
                    expandedSections = Set(viewModel.events.map { $0.id })
                    deleteTempFile()
                }

                Spacer()

                if let tempFileURL = tempFileURL {
                    ShareLink(item: tempFileURL) {
                        Text("Share Calendar Events")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    Button(action: saveToTempFile) {
                        Text("Create and Share Calendar Events")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Calendarco")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    func handleEventChange() {
        if tempFileURL != nil {
            deleteTempFile()
        }
    }

    func saveToTempFile() {
        viewModel.createICSData()
        guard let icsData = viewModel.icsData else { return }

        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileURL = tempDirectory.appendingPathComponent("events.ics")

        do {
            try icsData.write(to: tempFileURL)
            self.tempFileURL = tempFileURL
        } catch {
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }

    func deleteTempFile() {
        if let tempFileURL = tempFileURL {
            do {
                try FileManager.default.removeItem(at: tempFileURL)
                print("Temporary file deleted: \(tempFileURL)")
            } catch {
                print("Failed to delete temporary file: \(error)")
            }
            self.tempFileURL = nil
        }
    }

    func deleteEvent(at offsets: IndexSet) {
        offsets.map { viewModel.events[$0].id }.forEach { expandedSections.remove($0) }
        viewModel.events.remove(atOffsets: offsets)
        handleEventChange()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
