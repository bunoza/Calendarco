import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NewEventView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("New Events")
                }
                .tag(MainViewModel.Tab.newEvent)
                .environmentObject(viewModel)

            EventsHistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Events History")
                }
                .tag(MainViewModel.Tab.history)
                .environmentObject(viewModel)
        }
        .task {
            viewModel.deleteOldFiles()
        }
    }
}
