import SwiftUI


@main
struct Cashy_2_App: App {
    @StateObject private var appData = AppData()
    @StateObject private var tutorial = AppTutorialController()

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
                    .id(appData.hasCompletedOnboarding ? "main-app-flow" : "onboarding-flow")
                } else {
                    LoginView()
                }
            }
            .environmentObject(appData)
            .environmentObject(tutorial)
            .onChange(of: appData.isLoggedIn) { _, isLoggedIn in
                if !isLoggedIn {
                    tutorial.reset()
                }
            }
        }
    }
}
