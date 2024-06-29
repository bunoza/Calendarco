import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

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

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
