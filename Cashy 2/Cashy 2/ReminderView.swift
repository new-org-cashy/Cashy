import SwiftUI // Importiert das SwiftUI Framework für UI-Elemente

// Die Erinnerungsansicht verwaltet Auswahl, Vorschau und lokale Speicherung der Spar-Erinnerungen.
// MARK: - Optionen für Erinnerungen
enum ReminderOption: String, Codable { // Definiert die verschiedenen Erinnerungsoptionen
    case daily, weekly, monthly, everyXDays, specificDays // Täglich, Wöchentlich, Monatlich, Alle X Tage, Bestimmte Tage
}

// MARK: - Wochentage
struct WeekDay: Identifiable { // Struktur für einen Wochentag
    let id = UUID() // Eindeutige ID für SwiftUI-Listen
    let short: String // Kurze Darstellung des Tages ("M", "D", ...)
    let weekdayIndex: Int // Index des Wochentags (1=Sonntag, 2=Montag, ...)
}

// MARK: - ReminderView
struct ReminderView: View { // Haupt-View für Erinnerungen
    @EnvironmentObject private var tutorial: AppTutorialController

    // MARK: - States (Veränderbare Werte)
    @State private var selectedOption: ReminderOption? = nil // Welche Option ist ausgewählt
    @State private var xDays: Int = 1 // Anzahl Tage bei "Alle X Tage"
    @State private var selectedDays: Set<Int> = [] // Gewählte Wochentage für spezifische Tage
    @State private var isSaved = false // Ob die Einstellung gespeichert wurde
    @State private var selectionDate = Date() // Aktuelles Datum für Berechnungen

    // MARK: - Wochentage für Anzeige
    let weekDays: [WeekDay] = [
        WeekDay(short: "M", weekdayIndex: 2),
        WeekDay(short: "D", weekdayIndex: 3),
        WeekDay(short: "M", weekdayIndex: 4),
        WeekDay(short: "D", weekdayIndex: 5),
        WeekDay(short: "F", weekdayIndex: 6),
        WeekDay(short: "S", weekdayIndex: 7),
        WeekDay(short: "S", weekdayIndex: 1)
    ]

    var body: some View {
        ZStack { // Hintergrund und Inhalt übereinander
            Color.green.opacity(0.25).ignoresSafeArea() // Grüner halbtransparenter Hintergrund

            VStack(alignment: .leading, spacing: 30) { // Vertikale Anordnung der Elemente

                Text("Erinnerungen") // Titel
                    .font(.largeTitle) // Große Schrift
                    .fontWeight(.bold) // Fett
                    .frame(maxWidth: .infinity, alignment: .center) // Zentriert
                    .foregroundColor(.black) // Schwarz

                Text("Wie oft möchtest du erinnert werden?") // Untertitel
                    .font(.title2) // Etwas kleiner
                    .fontWeight(.semibold)
                    .foregroundColor(.black)

                // Verschiedene Optionen
                optionRow(title: "Täglich", option: .daily) // Täglich auswählen
                optionRow(title: "Wöchentlich", option: .weekly) // Wöchentlich auswählen
                optionRow(title: "Monatlich", option: .monthly) // Monatlich auswählen

                // Option Alle X Tage
                VStack(alignment: .leading, spacing: 12) {
                    optionRow(title: "Alle \(xDays) Tage", option: .everyXDays)

                    if selectedOption == .everyXDays { // Zeigt Stepper nur, wenn diese Option gewählt ist
                        Stepper("Alle \(xDays) Tage", value: $xDays, in: 1...30) // Mit Stepper Anzahl ändern
                            .disabled(isSaved) // Deaktiviert, wenn gespeichert
                            .foregroundColor(.black)
                    }
                }

                // Option Bestimmte Tage
                VStack(alignment: .leading, spacing: 14) {
                    optionRow(title: "Bestimmte Tage", option: .specificDays)

                    if selectedOption == .specificDays { // Zeigt Buttons für Wochentage
                        HStack(spacing: 14) {
                            ForEach(weekDays) { day in // Jeden Tag anzeigen
                                Button { // Wenn Button gedrückt
                                    toggleDay(day.weekdayIndex) // Tag auswählen/abwählen
                                } label: {
                                    Text(day.short) // Kürzel des Tages anzeigen
                                        .font(.title3)
                                        .frame(width: 44, height: 44) // Größe des Buttons
                                        .background( // Hintergrundfarbe
                                            selectedDays.contains(day.weekdayIndex)
                                            ? Color.orange // Wenn ausgewählt
                                            : Color.gray.opacity(0.3) // Wenn nicht ausgewählt
                                        )
                                        .foregroundColor(.black) // Schriftfarbe
                                        .clipShape(Circle()) // Rund
                                }
                                .disabled(isSaved) // Button deaktivieren, wenn gespeichert
                            }
                        }
                    }
                }
                .tutorialTarget(.reminderOptions)

                Spacer() // Abstand nach unten

                Text(nextReminderText) // Zeigt nächste Erinnerung an
                    .foregroundColor(.gray)

                if selectedOption != nil { // Wenn eine Option gewählt wurde
                    // Speichern friert die aktuelle Auswahl ein,
                    // Löschen setzt die Konfiguration wieder in den Ausgangszustand zurück.
                    HStack(spacing: 16) { // Buttons horizontal

                        // Löschen-Button
                        Button {
                            resetAll() // Alles zurücksetzen
                            saveToUserDefaults() // Änderungen speichern
                        } label: {
                            Text("Löschen")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.85))
                                .foregroundColor(.black)
                                .cornerRadius(30)
                        }

                        if !isSaved { // Nur anzeigen, wenn noch nicht gespeichert
                            Button {
                                isSaved = true // Status auf gespeichert setzen
                                selectionDate = Date() // Datum aktualisieren
                                saveToUserDefaults() // Speichern
                            } label: {
                                Text("Speichern")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.black)
                                    .cornerRadius(30)
                            }
                        }
                    }
                }
            }
            .padding() // Innenabstand
            .onAppear { // Wenn View erscheint
                loadFromUserDefaults() // Einstellungen laden
            }
        }
        .onAppear {
            // Die Erinnerungsseite kann im Tutorial von Home oder von der Statistik aus erreicht werden.
            // Beide möglichen Einstiegspunkte werden deshalb hier auf denselben letzten Schritt zusammengeführt.
            tutorial.completeNavigation(from: .homeReminderButton, to: .reminderOptions)
            tutorial.completeNavigation(from: .settingsStatsDetails, to: .reminderOptions)
        }
        .tutorialSpotlightHost()
    }

    // MARK: - Option Row
    func optionRow(title: String, option: ReminderOption) -> some View { // Zeigt eine Option als Button
        Button {
            selectedOption = option // Option auswählen
        } label: {
            HStack(spacing: 16) {
                Circle() // Kreis als Auswahlindikator
                    .fill(selectedOption == option ? Color.orange : Color.gray.opacity(0.4))
                    .frame(width: 18, height: 18)
                Text(title) // Titel anzeigen
                    .font(.title3)
                    .foregroundColor(.black)
                Spacer() // Abstand rechts
            }
        }
        .disabled(isSaved) // Button deaktivieren, wenn gespeichert
    }

    // MARK: - Nächste Erinnerung berechnen
    var nextReminderText: String { // Text für nächste Erinnerung
        // Aus der ausgewählten Regel wird eine einfache menschenlesbare Vorschau erzeugt,
        // damit der Nutzer direkt versteht, wann Cashy wieder erinnern würde.
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: selectionDate) // Wochentag heute

        switch selectedOption {
        case .daily: return "Nächste Erinnerung: morgen"
        case .weekly: return "Nächste Erinnerung: in 7 Tagen"
        case .monthly: return "Nächste Erinnerung: in ca. 30 Tagen"
        case .everyXDays: return "Nächste Erinnerung: in \(xDays) Tagen"
        case .specificDays:
            guard !selectedDays.isEmpty else { return "Keine Tage ausgewählt" } // Wenn keine Tage gewählt
            let nextDays = selectedDays
                .map { ($0 - today + 7) % 7 } // Berechnet Abstand zum nächsten gewählten Tag
                .filter { $0 > 0 } // Nur zukünftige Tage
            if let minDays = nextDays.min() { return "Nächste Erinnerung: in \(minDays) Tagen" }
            return "Nächste Erinnerung: heute" // Wenn heute dran
        default: return "Keine Erinnerung gesetzt"
        }
    }

    // MARK: - Tage auswählen/abwählen
    func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day) // Wenn schon ausgewählt, entfernen
        } else {
            selectedDays.insert(day) // Wenn nicht ausgewählt, hinzufügen
        }
    }

    // MARK: - Alles zurücksetzen
    func resetAll() {
        selectedOption = nil
        xDays = 1
        selectedDays.removeAll()
        isSaved = false
        selectionDate = Date()
    }

    // MARK: - Persistenz
    func saveToUserDefaults() { // Speichert Einstellungen lokal
        // Die Erinnerung wird lokal persistiert, damit die Auswahl beim nächsten Öffnen erhalten bleibt.
        let defaults = UserDefaults.standard
        defaults.set(selectedOption?.rawValue, forKey: "ReminderOption")
        defaults.set(xDays, forKey: "ReminderXDays")
        defaults.set(Array(selectedDays), forKey: "ReminderSelectedDays")
        defaults.set(isSaved, forKey: "ReminderIsSaved")
        defaults.set(selectionDate, forKey: "ReminderSelectionDate")
    }

    func loadFromUserDefaults() { // Lädt gespeicherte Einstellungen
        // Beim Öffnen wird der letzte bekannte Stand wieder in die UI zurückgespielt.
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: "ReminderOption") {
            selectedOption = ReminderOption(rawValue: raw)
        }
        xDays = defaults.integer(forKey: "ReminderXDays")
        selectedDays = Set(defaults.array(forKey: "ReminderSelectedDays") as? [Int] ?? [])
        isSaved = defaults.bool(forKey: "ReminderIsSaved")
        selectionDate = defaults.object(forKey: "ReminderSelectionDate") as? Date ?? Date()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ReminderView() // Zeigt Vorschau der ReminderView
            .environmentObject(AppTutorialController())
    }
}
