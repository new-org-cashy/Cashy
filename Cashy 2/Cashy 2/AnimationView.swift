import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.5

    var body: some View {
        if isActive {
            // Hier deine Haupt-App
            ContentView()
        } else {
            // Splash Screen
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


