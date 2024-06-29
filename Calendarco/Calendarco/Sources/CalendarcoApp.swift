import FirebaseCore
import SwiftData
import SwiftUI

@main
struct CalendarcoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let modelContainer: ModelContainer = try! ModelContainer(for: EventEntity.self)

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: MainViewModel(modelContext: modelContainer.mainContext))
                .modelContainer(for: [EventEntity.self])
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        FirebaseApp.configure()
        return true
    }
}
