import SwiftUI
import Firebase
import FirebaseStorage

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var fileName: String = ""
    
    private var generateFileButton: some View {
        Button {
            viewModel.saveToTempFile(fileName: fileName)
        } label: {
            Text("Generate Calendar File")
                .font(.title3)
                .padding(6)
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .disabled(viewModel.events.isEmpty)
    }
    
    @ViewBuilder
    private var shareButton: some View {
        if let tempFileURL = viewModel.tempFileURL {
            ShareLink(item: tempFileURL) {
                Text("Share File")
                    .font(.title3)
                    .padding(6)
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
    }
    
    private var showQRCodeButton: some View {
        Button(action: { showQRCode = true }) {
            Text("Show QR Code")
                .font(.title3)
                .padding(6)
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .disabled(viewModel.downloadURL == nil)
        .sheet(isPresented: $showQRCode) {
            if let url = viewModel.downloadURL {
                QRCodeView(url: url)
                    .presentationDetents([.medium])
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("File name", text: $fileName)
                    }
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
                                    viewModel.handleEventChange()
                                }
                            DatePicker("Start Date", selection: $event.startDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.startDate) {
                                    viewModel.handleEventChange()
                                }
                            DatePicker("End Date", selection: $event.endDate, displayedComponents: [.date, .hourAndMinute])
                                .onChange(of: event.endDate) {
                                    viewModel.handleEventChange()
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
                                viewModel.handleEventChange()
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
                    viewModel.deleteTempFile()
                }
                if viewModel.tempFileURL != nil {
                    HStack {
                        shareButton
                        showQRCodeButton
                    }
                } else {
                    generateFileButton
                }
            }
            .task {
                viewModel.deleteOldFiles()
            }
            .navigationTitle("Calendarco")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func deleteEvent(at offsets: IndexSet) {
        offsets.map { viewModel.events[$0].id }.forEach { expandedSections.remove($0) }
        viewModel.events.remove(atOffsets: offsets)
        viewModel.handleEventChange()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
