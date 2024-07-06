import SwiftData
import SwiftUI

struct NewEventView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var viewModel = NewEventViewModel()
    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var recurrenceRule: RecurrenceOption = .none
    @State private var showMaxEventsAlert = false
    @State private var showMaxFilesAlert = false

    @Query private var events: [EventEntity]

    private var generateFileButton: some View {
        Button {
            if events.count > 19 {
                showMaxFilesAlert = true
            } else {
                viewModel.createICSData()
                if let icsData = viewModel.icsData {
                    saveToTempFile(fileName: mainViewModel.fileName, icsData: icsData)
                }
            }
        } label: {
            Text("Generate Calendar File")
                .font(.title3)
                .padding(6)
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .disabled(viewModel.events.isEmpty)
        .padding(.bottom)
        .alert("Maximum number of files", isPresented: $showMaxFilesAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("You have reached a limit for number of generated files.")
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let tempFileURL = mainViewModel.tempFileURL {
            ShareLink(item: tempFileURL) {
                Text("Share File")
                    .font(.title3)
                    .padding(6)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
    }

    @ViewBuilder
    private var showQRCodeButton: some View {
        if mainViewModel.downloadURL != nil {
            Button(action: { showQRCode = true }) {
                Text("Show QR Code")
                    .font(.title3)
                    .padding(6)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .sheet(isPresented: $showQRCode) {
                if let url = mainViewModel.downloadURL {
                    QRCodeView(url: url)
                        .presentationDetents([.medium])
                }
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .padding()
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("File name", text: $mainViewModel.fileName)
                            .overlay {
                                HStack {
                                    Spacer()
                                    if !mainViewModel.fileName.isEmpty {
                                        Button {
                                            mainViewModel.fileName = ""
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                    }
                    ForEach($viewModel.events) { $event in
                        EventDisclosureView(event: $event, expandedSections: $expandedSections)
                    }
                    .onDelete(perform: deleteEvent)

                    Section {} footer: {
                        Button {
                            if viewModel.events.count > 19 {
                                showMaxEventsAlert = true
                            } else {
                                withAnimation {
                                    expandedSections = Set()
                                    viewModel.addEvent()
                                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Add Event")
                                Spacer()
                            }
                        }
                        .alert("Maximum number of events", isPresented: $showMaxEventsAlert) {
                            Button("OK", role: .cancel, action: {})
                        } message: {
                            Text("You have reached a limit for number of events in single file.")
                        }
                    }
                    Section {} footer: {
                        if mainViewModel.tempFileURL != nil {
                            HStack(alignment: .center) {
                                shareButton
                                showQRCodeButton
                            }
                        } else {
                            generateFileButton
                        }
                    }
                }
                .onChange(of: mainViewModel.events) { _, newEvents in
                    viewModel.events = newEvents
                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                }
                .onChange(of: mainViewModel.fileName) {
                    viewModel.handleEventChange(mainViewModel: mainViewModel)
                }
            }
            .navigationTitle("New Events")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func deleteEvent(at offsets: IndexSet) {
        offsets.map { viewModel.events[$0].id }.forEach { expandedSections.remove($0) }
        viewModel.events.remove(atOffsets: offsets)
        viewModel.handleEventChange(mainViewModel: mainViewModel)
    }

    func saveToTempFile(fileName: String, icsData: Data) {
        let tempDirectory = FileManager.default.temporaryDirectory
        let finalFileName = fileName.isEmpty ? "generated_events.ics" : "\(fileName).ics"
        let tempFileURL = tempDirectory.appendingPathComponent(finalFileName)

        do {
            try icsData.write(to: tempFileURL)
            mainViewModel.tempFileURL = tempFileURL

            viewModel.manager.uploadFileToFirebaseStorage(fileURL: tempFileURL) { downloadURL in
                guard let downloadURL = downloadURL else {
                    print("Failed to upload file to Firebase Storage")
                    return
                }

                let newFile = EventEntity(
                    fileName: fileName,
                    creationDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    downloadURL: downloadURL.absoluteString
                )
                mainViewModel.downloadURL = downloadURL
                context.insert(newFile)
                newFile.events = viewModel.events
                try? context.save()
            }
        } catch {
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }
}
