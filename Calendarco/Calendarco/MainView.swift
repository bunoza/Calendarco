import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CalendarEventViewModel()
    @State private var tempFileURL: URL? = nil
    @State private var expandedSections: Set<UUID> = []

    var body: some View {
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

                Button(action: {
                    viewModel.addEvent()
                    handleEventChange() // Ensure the file is deleted when a new event is added
                }) {
                    Text("Add Event")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

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
        .padding()
        .onAppear {
            // Initialize expandedSections with all event IDs to expand them by default
            expandedSections = Set(viewModel.events.map { $0.id })

            // Cleanup any leftover temporary files
            deleteTempFile()
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
