import SwiftUI

// Dieser Screen kapselt einen einfachen Splash-Ablauf:
// erst wird das Branding animiert eingeblendet, danach wird in die Hauptansicht gewechselt.
struct SplashScreen: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        if isActive {
            // Nach der kurzen Intro-Animation wird direkt der eigentliche App-Content angezeigt.
            ContentView()
        } else {
            // Solange der Splash aktiv ist, wird nur Logo plus Einstiegshintergrund dargestellt.
            VStack {
                Image("deinLogo") // dein Logo-Bild
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white) // Hintergrundfarbe
            .onAppear {
                // Die Animation vergrößert das Logo leicht und blendet es ein,
                // bevor der Splash automatisch in den Content übergeht.
                withAnimation(.easeIn(duration: 1.0)) {
                    self.scale = 1.2
                    self.opacity = 1.0
                }
                // Splash nach 1.5 Sekunden ausblenden
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

