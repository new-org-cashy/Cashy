import SwiftUI

// Diese View ist der erste Bildschirm der App.
// Hier sieht der Nutzer zuerst das Logo und den Start-Button.
struct WelcomeView: View {

    // Dieser Wert steuert die Kreis-Animation im Hintergrund.
    @State private var animateCircle = false
    // Dieser Wert entscheidet, ob noch der Startbildschirm oder schon der Login gezeigt wird.
    @State private var showLogin = false

    var body: some View {
        // ZStack legt mehrere Ansichten übereinander.
        ZStack {
            // Wenn showLogin true ist, wechseln wir zum Login.
            if showLogin {
                LoginView()
                    // Der Login wird weich eingeblendet.
                    .transition(.opacity)
            } else {
                // Sonst zeigen wir weiter den Welcome-Screen.
                content
            }
        }
    }

    var content: some View {
        // Hier bauen wir den eigentlichen Startbildschirm auf.
        ZStack {
            // Weißer Hintergrund über den ganzen Bildschirm.
            Color.white
                .ignoresSafeArea()

            // Das Bild zeigt das Branding der App.
            // Es liegt im Hintergrund und ist etwas nach unten verschoben.
            Image("mask")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .opacity(0.9)
                .offset(y: 120)


            // Der grüne Kreis ist ein Deko-Element im Hintergrund.
            // Seine Größe und Position ändern sich, wenn der Nutzer startet.
            Circle()
                .fill(Color.green.opacity(0.25))
                .frame(
                    // Vor dem Klick ist der Kreis kleiner.
                    // Nach dem Klick wird er sehr groß.
                    width: animateCircle ? 1200 : 360,
                    height: animateCircle ? 1200 : 360
                )
                .offset(
                    // Vor dem Klick sitzt der Kreis leicht versetzt.
                    // Nach dem Klick wandert er in die Mitte.
                    x: animateCircle ? 0 : 10,
                    y: animateCircle ? 0 : -200
                )
                // Diese Animation macht die Bewegung weich.
                .animation(.easeInOut(duration: 0.6), value: animateCircle)

            // In diesem VStack liegen Text und Button untereinander.
            VStack {
                // Abstand nach oben.
                Spacer().frame(height: 80)

                // Hier stehen App-Name und Untertitel.
                VStack(spacing: 10) {
                    // Großer App-Name.
                    Text("Cashy")
                        .font(.system(size: 52, weight: .bold))

                    // Kurzer Satz, der erklärt, worum es in der App geht.
                    Text("Mit Cashy kannst du es dir leisten!")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.gray)
                        // Der Text wird mittig ausgerichtet.
                        .multilineTextAlignment(.center)
                        // Etwas Abstand links und rechts.
                        .padding(.horizontal, 40)
                }

                // Dieser Spacer schiebt den Button weiter nach unten.
                Spacer()

                Button(action: {
                    // Beim Klick starten wir zuerst die Kreis-Animation.
                    animateCircle = true

                    // Nach einer kurzen Pause wechseln wir zum Login.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showLogin = true
                        }
                    }
                }) {
                    Text("Los geht's")
                        .font(.headline)
                        .foregroundColor(.white)
                        // Der Button nutzt fast die ganze Breite.
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Der Hintergrund ist ein grüner Farbverlauf.
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.green,
                                    Color.green.opacity(0.8),
                                    Color.green.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        // Abgerundete Ecken für einen weicheren Look.
                        .cornerRadius(18)
                        // Abstand zum linken und rechten Rand.
                        .padding(.horizontal, 32)
                }

                // Abstand nach unten.
                Spacer().frame(height: 50)
            }
        }
    }
}

// MARK: - LoginView
// Diese View ist nur ein alter Platzhalter.
// Der echte Login läuft über LoginView oben.
struct loginView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Einfacher Platzhalter-Text.
            Text("Login Screen")
                .font(.largeTitle)
        }
    }
}

// MARK: - Preview

#Preview {
    // Vorschau für Xcode.
    WelcomeView()
}
