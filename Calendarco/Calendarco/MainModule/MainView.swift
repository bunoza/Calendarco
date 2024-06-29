import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = MainViewModel()
    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var fileName: String = ""
    @State private var recurrenceRule: RecurrenceOption = .none

    var body: some View {
        TabView {
            NavigationView {
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
                                TextField("Event Description", text: $event.description)
                                    .onChange(of: event.description) {
                                        viewModel.handleEventChange()
                                    }
                                TextField("Event URL", text: $event.url)
                                    .onChange(of: event.url) {
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
                                Picker("Recurrence", selection: $event.recurrenceRule) {
                                    ForEach(RecurrenceOption.allCases, id: \.self) {
                                        Text($0.rawValue)
                                            .tag($0)
                                    }
                                }
                                .onChange(of: event.recurrenceRule) {
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
                        Section {} footer: {
                            if viewModel.tempFileURL != nil {
                                HStack(alignment: .center) {
                                    shareButton
                                    showQRCodeButton
                                }
                            } else {
                                generateFileButton
                            }
                        }
                    }
                    .onAppear {
                        expandedSections = Set(viewModel.events.map { $0.id })
                        viewModel.deleteTempFile()
                    }
                }
                .task {
                    viewModel.deleteOldFiles()
                }
                .navigationTitle("New Events")
                .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Image(systemName: "plus.circle")
                Text("New Events")
            }

            NavigationView {
                EventsHistoryView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("Events History")
            }
        }
    }

    private var generateFileButton: some View {
        Button {
            viewModel.saveToTempFile(fileName: fileName, context: context)
        } label: {
            Text("Generate Calendar File")
                .font(.title3)
                .padding(6)
        }
        .buttonStyle(BorderedProminentButtonStyle())
        .disabled(viewModel.events.isEmpty)
        .padding(.bottom)
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

    @ViewBuilder
    private var showQRCodeButton: some View {
        if viewModel.downloadURL != nil {
            Button(action: { showQRCode = true }) {
                Text("Show QR Code")
                    .font(.title3)
                    .padding(6)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .sheet(isPresented: $showQRCode) {
                if let url = viewModel.downloadURL {
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
