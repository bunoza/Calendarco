import SwiftData
import SwiftUI

struct NewEventView: View {
    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var viewModel = NewEventViewModel()
    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var recurrenceRule: RecurrenceOption = .none

    private var generateFileButton: some View {
        Button {
            viewModel.createICSData()
            if let icsData = viewModel.icsData {
                mainViewModel.saveToTempFile(fileName: mainViewModel.fileName, icsData: icsData)
            }
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
                    }
                    ForEach($viewModel.events) { $event in
                        EventDisclosureView(event: $event, expandedSections: $expandedSections)
                    }
                    .onDelete(perform: deleteEvent)

                    Section {} footer: {
                        Button {
                            withAnimation {
                                viewModel.addEvent()
                                viewModel.handleEventChange(mainViewModel: mainViewModel)
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
                .onAppear {
                    expandedSections = Set(viewModel.events.map { $0.id })
                }
                .onChange(of: mainViewModel.events) { _, newEvents in
                    viewModel.events = newEvents
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
}
