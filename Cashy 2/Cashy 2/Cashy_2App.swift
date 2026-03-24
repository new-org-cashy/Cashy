import SwiftUI


@main
struct Cashy_2_App: App {
    @StateObject private var appData = AppData()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(appData)
        }
    }
}
