import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        TabView {
            NewEventView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("New Events")
                }

            EventsHistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Events History")
                }
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
