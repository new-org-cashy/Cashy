import SwiftUI


@main
struct Cashy_2_App: App {
    @StateObject private var appData = AppData()

    var body: some Scene {
        WindowGroup {
            Group {
                if appData.isLoggedIn {
                    NavigationStack {
                        if appData.hasCompletedOnboarding {
                            HomeView()
                        } else {
                            Fragen()
                        }
                    }
                } else {
                    LoginView()
                }
            }
                .environmentObject(appData)
        }
    }
}
