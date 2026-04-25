import SwiftUI


@main
// Der App-Einstieg entscheidet auf Root-Ebene zwischen Login, Onboarding und Haupt-App
// und hängt die globalen EnvironmentObjects für Daten und Tutorial an den gesamten Baum.
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
                    // Beim Wechsel vom Onboarding in die Haupt-App wird der Stack neu aufgebaut,
                    // damit keine alten Onboarding-Screens im Navigationspfad hängen bleiben.
                    .id(appData.hasCompletedOnboarding ? "main-app-flow" : "onboarding-flow")
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(appData)
            .environmentObject(tutorial)
            .onChange(of: appData.isLoggedIn) { _, isLoggedIn in
                // Beim Ausloggen wird das Tutorial zurückgesetzt,
                // damit ein neuer Login wieder mit sauberem Zustand startet.
                if !isLoggedIn {
                    tutorial.reset()
                }
            }
        }
    }
}
