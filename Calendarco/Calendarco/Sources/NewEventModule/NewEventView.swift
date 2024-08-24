import SwiftData
import SwiftUI

struct NewEventView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.openURL) var openURL

    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var viewModel = NewEventViewModel()

    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var recurrenceRule: RecurrenceOption = .none
    @State private var showMaxEventsAlert = false
    @State private var showMaxFilesAlert = false
    @State private var fileName = ""
    @State private var isLoading = false

    @Query private var events: [EventEntity]

    private let fileManager = FileManager()

    private var tempFileExists: Bool {
        if let tempFileURL = mainViewModel.eventEntity?.tempFileURL {
            return fileManager.fileExists(atPath: tempFileURL.path())
        }
        return false
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    private var generateFileButton: some View {
        Button {
            if events.count >= Constants.maxFilesCount {
                showMaxFilesAlert = true
            } else {
                isLoading = true
                viewModel.createICSData()
                if let icsData = viewModel.icsData {
                    saveToTempFile(fileName: fileName, icsData: icsData)
                } else {
                    isLoading = false
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
        if let tempFileURL = mainViewModel.eventEntity?.tempFileURL, tempFileExists {
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
        if mainViewModel.eventEntity?.downloadURL != nil {
            Button(action: { showQRCode = true }) {
                Text("Show QR Code")
                    .font(.title3)
                    .padding(6)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .sheet(isPresented: $showQRCode) {
                if let downloadString = mainViewModel.eventEntity?.downloadURL,
                   let url = URL(string: downloadString)
                {
                    QRCodeView(url: url)
                        .presentationDetents([.medium])
                }
            }
        }
    }

    @ViewBuilder
    private var menu: some View {
        if let event = mainViewModel.eventEntity,
           let urlString = event.downloadURL,
           let url = URL(string: urlString)
        {
            Menu {
                Button {
                    openURL(url)
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Add to my calendar")
                    }
                }
                .disabled(event.expirationDate < Date())
                Button {
                    showQRCode = true
                } label: {
                    HStack {
                        Image(systemName: "qrcode")
                        Text("Show QR code")
                    }
                }
                .disabled(event.expirationDate < Date())
            } label: {
                Text("Export")
                    .buttonStyle(BorderedProminentButtonStyle())
            }
        } else {
            ProgressView()
                .progressViewStyle(.circular)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("File name", text: $fileName)
                            .overlay {
                                HStack {
                                    Spacer()
                                    if !fileName.isEmpty {
                                        Button {
                                            fileName = ""
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
                            if viewModel.events.count >= Constants.maxEventsCount {
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
                        HStack {
                            Spacer()
                            if !isLoading {
                                if tempFileExists {
                                    menu
                                } else {
                                    generateFileButton
                                }
                            } else {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            }
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $showQRCode) {
                        if let downloadString = mainViewModel.eventEntity?.downloadURL,
                           let url = URL(string: downloadString)
                        {
                            QRCodeView(url: url)
                                .presentationDetents([.medium])
                        }
                    }
                }
                .onChange(of: mainViewModel.eventEntity?.events) { _, newEvents in
                    guard let events = newEvents else {
                        return
                    }
                    viewModel.events = events
                }
                .onChange(of: fileName) {
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
            viewModel.manager.uploadFileToFirebaseStorage(fileURL: tempFileURL) { downloadURL in
                guard let downloadURL = downloadURL else {
                    print("Failed to upload file to Firebase Storage")
                    isLoading = false
                    return
                }

                let newFile = EventEntity(
                    fileName: fileName,
                    creationDate: Date(),
                    expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    downloadURL: downloadURL.absoluteString,
                    tempFileURL: tempFileURL
                )

                mainViewModel.eventEntity = newFile
                context.insert(newFile)
                newFile.events = viewModel.events
                try? context.save()
                isLoading = false
            }
        } catch {
            isLoading = false
            print("Failed to write .ics file to temporary directory: \(error)")
        }
    }
}
