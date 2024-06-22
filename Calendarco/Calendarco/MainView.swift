import SwiftUI
import Firebase
import FirebaseStorage

struct MainView: View {
    @StateObject private var viewModel = CalendarEventViewModel()
    @State private var tempFileURL: URL? = nil
    @State private var expandedSections: Set<UUID> = []
    @State private var isUploading = false  // State to track ongoing upload
    @State private var showQRCode = false   // State to manage QR code presentation
    @State private var downloadURL: URL? = nil  // State to store the download URL

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
                                .onChange(of: event.title) {
                                    handleEventChange()
                                }
                            DatePicker("Start Date", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.startDate) {
                                    handleEventChange()
                                }
                            DatePicker("End Date", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.endDate) {
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
                    // Initialize expandedSections with all event IDs to expand them by default
                    expandedSections = Set(viewModel.events.map { $0.id })

                    // Cleanup any leftover temporary files
                    deleteTempFile()
                }

                Spacer()

                if let tempFileURL = tempFileURL {
                    HStack {
                        ShareLink(item: tempFileURL) {
                            Text("Share File")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Button(action: { showQRCode = true }) {
                            Text("Show QR Code")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(downloadURL == nil)  // Disable QR Code button until download URL is available
                        .sheet(isPresented: $showQRCode) {
                            if let url = downloadURL {
                                QRCodeView(url: url)
                                    .presentationDetents([.medium])
                                    .interactiveDismissDisabled()
                            }
                        }
                    }
                } else {
                    Button(action: saveToTempFile) {
                        Text("Create and Share Calendar Events")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isUploading)  // Disable button if an upload is in progress
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
            
            // Upload the file to Firebase Storage
            uploadFileToFirebaseStorage(fileURL: tempFileURL)
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

    func uploadFileToFirebaseStorage(fileURL: URL) {
        guard !isUploading else { return }  // Prevent multiple simultaneous uploads

        isUploading = true
        let storage = Storage.storage()
        let storageRef = storage.reference().child("events/\(UUID().uuidString).ics")
        
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            self.isUploading = false  // Reset uploading state

            if let error = error {
                print("Failed to upload file to Firebase Storage: \(error)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("Download URL is nil")
                    return
                }
                
                print("File successfully uploaded to Firebase Storage: \(downloadURL)")
                self.downloadURL = downloadURL
            }
        }
    }
}

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL

    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                    .padding()
                }

                Spacer()
                
                Text("Scan to download the calendar file.")
                Text("File is available for 30 days.")
                
                if let qrCodeImage = generateQRCode(from: url.absoluteString) {
                    Image(uiImage: qrCodeImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Text("Failed to generate QR code")
                    Text("URL: \(url.absoluteString)")  // Display the URL for debugging
                }
                Spacer()
            }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            guard let outputImage = filter.outputImage else {
                return nil
            }

            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
