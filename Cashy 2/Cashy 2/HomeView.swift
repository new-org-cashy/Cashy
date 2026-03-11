import SwiftUI // Importiert das SwiftUI Framework, das für das Erstellen von Benutzeroberflächen verwendet wird

// MARK: - Activity Model
struct Activity: Identifiable { // Definiert ein Datenmodell für Aktivitäten, damit wir sie in Listen verwenden können
    let id = UUID() // Jede Aktivität bekommt eine eindeutige ID
    let text: String // Textbeschreibung der Aktivität
    let amount: String // Betrag der Aktivität (z.B. "-10€" oder "+5€")
}

// MARK: - Dummy Ziel Views
struct ZielView: View { var body: some View { Text("Hier geht es zu den Ausgaben").font(.title).foregroundColor(.green) } } // Einfache Ziel-View, zeigt Text an
struct PersonView: View { var body: some View { Text("Person View").font(.title) } } // Dummy-View für Personenseite
struct CartView: View { var body: some View { Text("Warenkorb View").font(.title) } } // Dummy-View für Warenkorb
struct settingsView: View { var body: some View { Text("Einstellungen View").font(.title) } } // Dummy-View für Einstellungen
struct VirtuelleWeltView: View { var body: some View { Text("Virtuelle Welt").font(.title) } } // Dummy-View für Virtuelle Welt

// MARK: - ActivityRow
struct ActivityRow: View { // Zeigt eine Zeile mit Aktivität und Betrag an
    let text: String // Text der Aktivität
    let amount: String // Betrag der Aktivität
    let color: Color // Farbe des Betrags (z.B. Rot für Minus, Grün für Plus)

    var body: some View {
        HStack { // Horizontale Anordnung von Text und Betrag
            Text(text) // Zeigt den Text der Aktivität
                .font(.subheadline) // Kleinere Schriftgröße
            Spacer() // Fügt Abstand zwischen Text und Betrag hinzu
            Text(amount) // Zeigt den Betrag
                .foregroundColor(color) // Farbe des Betrags
        }
        .padding(.vertical, 10) // Vertikales Padding (Abstand oben und unten)
        .padding(.horizontal) // Horizontaler Padding (Abstand links und rechts)
    }
}

// MARK: - Lavalampe-Hintergrund
struct LavaLampBackground: View { // Animierter Farbverlaufshintergrund
    @State private var start = UnitPoint.top // Startpunkt des Farbverlaufs
    @State private var end = UnitPoint.bottom // Endpunkt des Farbverlaufs

    var body: some View {
        LinearGradient( // Farbverlauf erstellen
            gradient: Gradient(colors: [
                Color.green.opacity(0.3),
                Color.green.opacity(0.1),
                Color.green.opacity(0.25)
            ]), // Farben des Verlaufs
            startPoint: start, // Startpunkt
            endPoint: end // Endpunkt
        )
        .ignoresSafeArea() // Hintergrund füllt den gesamten Bildschirm
        .onAppear { // Wird ausgeführt, wenn die View erscheint
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) { // Animation, die sich endlos wiederholt
                start = UnitPoint.bottomLeading // Startpunkt animieren
                end = UnitPoint.topTrailing // Endpunkt animieren
            }
        }
    }
}

// MARK: - HomeView
struct HomeView: View { // Hauptseite der App

    // Animation States für Buttons
    @State private var pressedVirtuelle = false // Für Pop-Effekt des Virtuelle Welt Buttons
    @State private var pressedAusgaben = false // Für Pop-Effekt des Ausgaben Buttons
    @State private var pressedPerson = false // Für Pop-Effekt des Person Buttons
    @State private var pressedCart = false // Für Pop-Effekt des Warenkorb Buttons
    @State private var pressedSettings = false // Für Pop-Effekt des Settings Buttons

    let currentSavings = "154€"
    let savingsGoal = "500€"

    // Werte für Progress Berechnung
    let currentSavingsValue: Double = 154
    let savingsGoalValue: Double = 500

    let activities: [Activity] = [ // Beispiel-Aktivitäten
        Activity(text: "→ Das wären 5 Döner…", amount: "-10€"),
        Activity(text: "", amount: "-5€"),
        Activity(text: "", amount: "-60€"),
        Activity(text: "", amount: "+10€"),
        Activity(text: "→ Hälfte vom Führerschein...", amount: "-47€"),
        Activity(text: "", amount: "+17€"),
        Activity(text: "", amount: "+5€")
    ]

    var body: some View {

        NavigationStack { // Erlaubt Navigation zu anderen Views

            ZStack { // Schichtenansicht, damit Hintergrund und Inhalt übereinander liegen
                // MARK: Animierter Hintergrund
                LavaLampBackground() // Fügt den animierten Lavalampe-Hintergrund hinzu

                VStack(spacing: 20) { // Vertikale Anordnung von Elementen mit Abstand

                    // MARK: Top Tabs
                    HStack(spacing: 12) { // Horizontale Anordnung der Tabs
                        Spacer()

                        Text("Home")
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.green.opacity(0.35))
                            .cornerRadius(20)
                            .foregroundColor(.black)

                        Rectangle()
                            .frame(width: 1, height: 20)
                            .foregroundColor(Color.gray.opacity(0.4))

                        NavigationLink(destination: VirtuelleWeltView()) {
                            Text("Virtuelle Welt")
                                .foregroundColor(.black)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(Color.gray.opacity(0.25))
                                .cornerRadius(12)
                                .scaleEffect(pressedVirtuelle ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: pressedVirtuelle)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in pressedVirtuelle = true }
                                .onEnded { _ in pressedVirtuelle = false }
                        )

                        Spacer()
                    }

                    // MARK: Savings Card
                    VStack(alignment: .leading, spacing: 25) {

                        Text("Bereits gespart:")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(currentSavings)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        // MARK: Sparfortschritt Balken
                        ProgressView(value: currentSavingsValue / savingsGoalValue)
                            .tint(.green)
                            .scaleEffect(x: 1, y: 2, anchor: .center)

                        Spacer().frame(height: 5)

                        HStack {
                            Text("Dein Ziel: \(savingsGoal)")
                                .font(.subheadline)
                                .foregroundColor(.black)

                            Spacer()

                            NavigationLink(destination: ZielView()) {
                                Text("Ausgaben >")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .scaleEffect(pressedAusgaben ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.1), value: pressedAusgaben)
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in pressedAusgaben = true }
                                    .onEnded { _ in pressedAusgaben = false }
                            )
                        }

                    }
                    .padding()
                    .padding(.bottom, 18)
                    .background(Color.green.opacity(0.22))
                    .cornerRadius(22)
                    .padding(.horizontal)

                    // MARK: Verlauf / Aktivitäten
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(activities.indices, id: \.self) { index in
                                ActivityRow(
                                    text: activities[index].text,
                                    amount: activities[index].amount,
                                    color: activities[index].amount.contains("-") ? .red : .green
                                )

                                if index < activities.count - 1 {
                                    Divider()
                                        .background(Color.gray.opacity(0.15))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.18))
                    .cornerRadius(22)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()

            }

            // MARK: Bottom Navigation
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 5) {
                    Divider()
                        .background(Color.gray.opacity(0.3))

                    HStack {

                        NavigationLink(destination: AccountView()) {
                            Image(systemName: "person")
                                .foregroundColor(.black)
                                .scaleEffect(pressedPerson ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: pressedPerson)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in pressedPerson = true }
                                .onEnded { _ in pressedPerson = false }
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)

                        NavigationLink(destination: CartView()) {
                            Image(systemName: "cart")
                                .foregroundColor(.black)
                                .scaleEffect(pressedCart ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: pressedCart)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in pressedCart = true }
                                .onEnded { _ in pressedCart = false }
                        )

                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.black)
                                .scaleEffect(pressedSettings ? 0.9 : 1.0)
                                .animation(.easeInOut(duration: 0.1), value: pressedSettings)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in pressedSettings = true }
                                .onEnded { _ in pressedSettings = false }
                        )
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    }
                    .font(.title)
                    .padding(.horizontal, 35)
                    .padding(.top, 16)
                    .padding(.bottom, 18)
                }
                .background(Color.gray.opacity(0.2))
            }

        }
    }
}

// MARK: Preview
#Preview {
    HomeView()
}
