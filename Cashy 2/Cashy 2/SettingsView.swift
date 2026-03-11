import SwiftUI // Importiert das SwiftUI Framework für UI-Elemente

// MARK: - SettingsView
struct SettingsView: View { // Haupt-View für die Einstellungen

    @Environment(\.dismiss) var dismiss // Ermöglicht das Schließen der View
    @State private var searchText: String = "" // Text im Suchfeld
    @State private var showSearch: Bool = false // Zeigt an, ob das Suchfeld sichtbar ist

    // Alle möglichen Einstellungen (Icon, Titel)
    let allSettings = [
        ("person", "Konto"),
        ("lock", "Datenschutz"),
        ("bell", "Erinnerungen"),
        ("chart.bar", "Verlauf & Statistiken"),
        ("globe", "Sprache"),
        ("questionmark.circle", "Hilfe-Center"),
        ("star", "Feedback geben"),
        ("info.circle", "Über Cashy"),
        ("arrow.backward.circle", "Abmelden")
    ]

    // Filtert die Einstellungen basierend auf dem Suchtext
    var filteredSettings: [(String, String)] {
        if searchText.isEmpty {
            return allSettings // Zeigt alle, wenn kein Text
        } else {
            return allSettings.filter {
                $0.1.lowercased().contains(searchText.lowercased()) // Filtert nach Titel
            }
        }
    }

    var body: some View {
        ZStack { // Hintergrund + Inhalt übereinander
            Color.green.opacity(0.25)
                .ignoresSafeArea() // Hintergrund über gesamte Fläche

            VStack(spacing: 0) { // Vertikale Anordnung

                // MARK: Header
                VStack(spacing: 12) {

                    HStack { // Horizontale Anordnung von Buttons und Titel
                        Button { // Zurück-Button
                            dismiss() // Schließt die View
                        } label: {
                            Image(systemName: "chevron.left") // Pfeil-Icon
                                .font(.title)
                                .foregroundColor(.black)
                        }

                        Spacer() // Abstand

                        Text("Einstellungen") // Titel
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Spacer() // Abstand

                        Button { // Such-Button
                            withAnimation {
                                showSearch.toggle() // Suchfeld ein-/ausblenden
                                if !showSearch {
                                    searchText = "" // Text löschen, wenn Suchfeld geschlossen
                                }
                            }
                        } label: {
                            Image(systemName: "magnifyingglass") // Lupen-Icon
                                .font(.title2)
                                .foregroundColor(.black.opacity(0.7))
                        }
                    }

                    // Suchfeld (nur sichtbar, wenn showSearch true)
                    if showSearch {
                        HStack {
                            TextField("Suchen …", text: $searchText) // Eingabefeld
                                .padding(10)
                                .background(Color.white.opacity(0.6)) // Hintergrund hell
                                .cornerRadius(12)

                            Button("Abbrechen") { // Abbrechen-Button
                                withAnimation {
                                    showSearch = false // Suchfeld ausblenden
                                    searchText = "" // Text löschen
                                }
                            }
                            .foregroundColor(.gray)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity)) // Animation beim Ein-/Ausblenden
                    }
                }
                .padding() // Innenabstand
                .background(Color.green.opacity(0.2)) // Hintergrundfarbe Header

                // MARK: Scrollbarer Inhalt
                ScrollView { // Scrollbare Liste
                    VStack(spacing: 12) {
                        ForEach(filteredSettings, id: \.1) { item in // Für jede gefilterte Einstellung
                            SettingsRow(icon: item.0, title: item.1) // Zeigt die Zeile
                        }

                        if filteredSettings.isEmpty { // Wenn nichts gefunden
                            Text("Keine Ergebnisse gefunden")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding() // Innenabstand
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Standard-Back-Button ausblenden
    }
}

// MARK: - SettingsRow
struct SettingsRow: View { // Zeile für eine Einstellung

    let icon: String // Icon-Name
    let title: String // Titel der Einstellung

    @ViewBuilder
    var destination: some View {
        if title == "Konto" {
            AccountView()
            
        } else if title == "Erinnerungen" {
            ReminderView()
            
        } else if title == "Verlauf & Statistiken" {
            SavingsGoalView()
            
        } else {
            SettingsDetailView(title: title)
        }
    }
    var body: some View {
        NavigationLink(destination: destination) { // Klickbarer Navigations-Link
            HStack(spacing: 18) {
                Image(systemName: icon) // Icon anzeigen
                    .font(.title2)
                    .frame(width: 30)
                    .foregroundColor(.black)

                Text(title) // Titel anzeigen
                    .font(.title3)
                    .foregroundColor(.black)

                Spacer() // Abstand rechts

                Image(systemName: "chevron.right") // Pfeil rechts
                    .foregroundColor(.gray)
            }
            .padding() // Innenabstand
            .background(Color.green.opacity(0.18)) // Hintergrundfarbe
            .cornerRadius(16) // Abgerundete Ecken
        }
    }
}

// MARK: - SettingsDetailView
struct SettingsDetailView: View { // Detail-View für einzelne Einstellungen

    let title: String // Titel der Detailseite

    var body: some View {
        ZStack {
            Color.green.opacity(0.25) // Hintergrundfarbe
                .ignoresSafeArea()

            Text(title) // Titel anzeigen
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle(title) // Navigationstitel
        .navigationBarTitleDisplayMode(.inline) // Inline-Modus
    }
}

// MARK: - ReminderView (Dummy)
struct reminderView: View { // Dummy-ReminderView, falls separat gebraucht
    var body: some View {
        ZStack {
            Color.green.opacity(0.25) // Hintergrund
                .ignoresSafeArea()

            Text("Erinnerungen") // Text anzeigen
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle("Erinnerungen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview { // Vorschau in Xcode
    NavigationStack {
        SettingsView()
    }
}
