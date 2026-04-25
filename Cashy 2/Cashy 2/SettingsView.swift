import SwiftUI // Importiert das SwiftUI Framework für UI-Elemente

// MARK: - SettingsView
struct SettingsView: View { // Haupt-View für die Einstellungen

    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var tutorial: AppTutorialController
    @Environment(\.dismiss) var dismiss // Ermöglicht das Schließen der View
    @State private var searchText: String = "" // Text im Suchfeld
    @State private var showSearch: Bool = false // Zeigt an, ob das Suchfeld sichtbar ist

    // Alle möglichen Einstellungen (Icon, Titel)
    let allSettings = [
        ("person", "Konto"),
        ("lock", "Datenschutz"),
        ("bell", "Erinnerungen"),
        ("globe", "Sprache"),
        ("questionmark.circle", "Hilfe-Center"),
        ("star", "Feedback geben"),
        ("info.circle", "Über Cashy"),
        ("arrow.backward.circle", "Abmelden"),
        ("trash", "Konto löschen")
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
        .navigationDestination(isPresented: $tutorial.navigateToStats) {
            SavingsGoalView()
        }
        .navigationDestination(isPresented: $tutorial.navigateToReminders) {
            ReminderView()
        }
        .tutorialSpotlightHost()
    }
}

// MARK: - SettingsRow
struct SettingsRow: View { // Zeile für eine Einstellung

    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var tutorial: AppTutorialController
    @Environment(\.dismiss) private var dismiss

    let icon: String // Icon-Name
    let title: String // Titel der Einstellung
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountSheet = false

    @ViewBuilder
    var destination: some View {
        if title == "Konto" {
            AccountView()
            
        } else if title == "Erinnerungen" {
            ReminderView()
            
        } else {
            SettingsDetailView(title: title)
        }
    }
    var body: some View {
        if title == "Abmelden" {
            Button {
                showLogoutAlert = true
            } label: {
                rowContent(showChevron: false)
            }
            .alert("Abmelden?", isPresented: $showLogoutAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Abmelden", role: .destructive) {
                    appData.logout()
                }
            } message: {
                Text("Du wirst aus der App abgemeldet und musst dich erneut anmelden.")
            }
        } else if title == "Konto löschen" {
            Button {
                showDeleteAccountSheet = true
            } label: {
                rowContent(showChevron: false)
            }
            .sheet(isPresented: $showDeleteAccountSheet) {
                DeleteAccountSheet()
            }
        } else if title == "Hilfe-Center" {
            Button {
                tutorial.restart()
                dismiss()
            } label: {
                rowContent(showChevron: true)
            }
        } else {
            NavigationLink(destination: destination) { // Klickbarer Navigations-Link
                rowContent(showChevron: true)
            }
        }
    }

    @ViewBuilder
    private func rowContent(showChevron: Bool) -> some View {
        let content = HStack(spacing: 18) {
            Image(systemName: icon) // Icon anzeigen
                .font(.title2)
                .frame(width: 30)
                .foregroundColor(.black)

            Text(title) // Titel anzeigen
                .font(.title3)
                .foregroundColor(.black)

            Spacer() // Abstand rechts

            if showChevron {
                Image(systemName: "chevron.right") // Pfeil rechts
                    .foregroundColor(.gray)
            }
        }
        .padding() // Innenabstand
        .background(Color.green.opacity(0.18)) // Hintergrundfarbe
        .cornerRadius(16) // Abgerundete Ecken

        content
    }
}

// MARK: - DeleteAccountSheet
struct DeleteAccountSheet: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @State private var password = ""
    @State private var showDeleteError = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.opacity(0.15)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    Text("Konto löschen")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Gib dein Passwort ein. Danach werden dein Konto, deine Zugangsdaten und alle gespeicherten Daten endgültig gelöscht.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Passwort")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)

                        SecureField("Passwort bestätigen", text: $password)
                            .padding(14)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }

                    Button {
                        let didDelete = appData.deleteCurrentAccount(password: password)

                        if didDelete {
                            dismiss()
                        } else {
                            showDeleteError = true
                        }
                    } label: {
                        Text("Konto endgültig löschen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(18)
                            .fontWeight(.semibold)
                    }
                    .disabled(password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Bestätigen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .alert("Löschen nicht möglich", isPresented: $showDeleteError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Das Passwort stimmt nicht. Das Konto wurde nicht gelöscht.")
            }
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
            .environmentObject(AppData())
            .environmentObject(AppTutorialController())
    }
}
