import SwiftData
import SwiftUI

struct NewEventView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = NewEventViewModel()
    @State private var expandedSections: Set<UUID> = []
    @State private var showQRCode = false
    @State private var fileName: String = ""
    @State private var recurrenceRule: RecurrenceOption = .none
    @EnvironmentObject private var mainViewModel: MainViewModel

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

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField("File name", text: $fileName)
                    }
                    ForEach($viewModel.events) { $event in
                        EventDisclosureView(event: $event, expandedSections: $expandedSections)
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
                .onChange(of: mainViewModel.events) { newEvents in
                    viewModel.events = newEvents
                }
            }
            .navigationTitle("New Events")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func deleteEvent(at offsets: IndexSet) {
        offsets.map { viewModel.events[$0].id }.forEach { expandedSections.remove($0) }
        viewModel.events.remove(atOffsets: offsets)
        viewModel.handleEventChange()
    }
}

struct NewEventView_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
            .environmentObject(MainViewModel())
    }
}
