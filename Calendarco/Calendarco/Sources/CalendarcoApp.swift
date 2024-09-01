import FirebaseCore
import SwiftData
import SwiftUI

@main
struct CalendarcoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var viewModel = StoreViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isCheckingSubscription {
                    LoadingView()
                } else if viewModel.isProductPurchased {
                    MainView()
                        .modelContainer(for: [EventEntity.self, Event.self])
                } else {
                    StoreView(viewModel: viewModel)
                }
            }
            .task {
                await viewModel.checkSubscriptionStatus()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
