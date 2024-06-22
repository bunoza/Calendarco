import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = CalendarEventViewModel()
    @State private var tempFileURL: URL? = nil

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Event 1")) {
                    TextField("Event Title", text: $viewModel.eventTitle1)
                    DatePicker("Start Date", selection: $viewModel.startDate1, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $viewModel.endDate1, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Event 2")) {
                    TextField("Event Title", text: $viewModel.eventTitle2)
                    DatePicker("Start Date", selection: $viewModel.startDate2, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $viewModel.endDate2, displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            if let tempFileURL = tempFileURL {
                ShareLink(item: tempFileURL) {
                    Text("Share Calendar Event")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: saveToTempFile) {
                    Text("Create and Share Calendar Event")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
