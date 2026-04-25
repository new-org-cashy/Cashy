import SwiftUI
import Charts

// Die Statistikansicht kombiniert Sparziel, Fortschritt und Auswertungen für Wochen oder Monate.
struct SavingsGoalView: View {
    // Zugriff auf das zentrale Datenmodell für Ziel, Sparstand und Statistikwerte.
    @EnvironmentObject private var appData: AppData
    // Zugriff auf den Tutorial-Controller, damit dieser Screen in den geführten Ablauf eingebunden bleibt.
    @EnvironmentObject private var tutorial: AppTutorialController
    // Mit dismiss kann die Ansicht programmgesteuert geschlossen werden, z. B. beim Tutorial-Rücksprung.
    @Environment(\.dismiss) private var dismiss

    // Dieser State merkt sich, ob das Diagramm Monats- oder Wochendaten anzeigen soll.
    @State private var selectedTimeframe: Timeframe = .months

    // Das Enum definiert die beiden Zeiträume, zwischen denen der Nutzer umschalten kann.
    enum Timeframe: String, CaseIterable {
        // Monatsansicht für einen breiteren Überblick über den Sparverlauf.
        case months = "Monate"
        // Wochenansicht für eine feinere, kurzfristige Betrachtung des Sparverlaufs.
        case weeks = "Wochen"
    }

    var body: some View {
        // Die ganze Seite ist vertikal aufgebaut: Kopfbereich, Fortschritt, Chart und Kennzahlen.
        VStack(spacing: 18) {
            // Der obere Bereich zeigt den aktuellen Sparstatus in Textform plus Fortschrittsbalken.
            HStack {
                // Fester Titel der Statistikseite.
                Text("Sparziel")
                    .font(.largeTitle)
                    .bold()

                // Der Spacer drückt Titel und Zielwert an die beiden Seiten des Headers.
                Spacer()

                // Hier wird das aktuelle Sparziel formatiert als Währung angezeigt.
                Text(appData.formatCurrency(appData.savingsGoal))
                    .font(.title2)
                    .bold()
            }

            // Diese Karte fasst den bereits erreichten Sparstand kompakt zusammen.
            VStack(alignment: .leading, spacing: 14) {
                // Beschriftung für den aktuellen Sparbetrag.
                Text("Bereits gespart")
                    .font(.headline)

                // Anzeige des aktuell gesparten Betrags in formatierter Währung.
                Text(appData.formatCurrency(appData.currentSavings))
                    .font(.title)
                    .fontWeight(.bold)

                // Der Fortschrittsbalken zeigt den Anteil des Sparziels, der schon erreicht wurde.
                ProgressView(value: appData.savingsProgress)
                    // Die Farbgebung kommt zentral aus den App-Farben.
                    .tint(AppColors.primaryGreen)
                    // Der Balken wird optisch höher gezogen, damit er präsenter wirkt.
                    .scaleEffect(x: 1, y: 2, anchor: .center)

                // Der Hilfetext erklärt, woran sich Balken und Diagramm inhaltlich orientieren.
                Text("Der Balken und das Diagramm orientieren sich an deinem eingetragenen Sparstand.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            // Innenabstand für die gesamte Fortschrittskarte.
            .padding()
            // Halbtransparenter Kartenhintergrund, damit sich der Block vom Seitenhintergrund absetzt.
            .background(Color.white.opacity(0.35))
            // Abgerundete Ecken für den Karten-Look.
            .cornerRadius(20)
            // Dieses Element wird im Tutorial als Statistik-Ziel hervorgehoben.
            .tutorialTarget(.settingsStatsDetails)

            // Der Picker lässt zwischen Monats- und Wochenansicht umschalten.
            Picker("Zeitraum", selection: $selectedTimeframe) {
                // Beide Enum-Fälle werden automatisch als auswählbare Segmente gerendert.
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    // Angezeigt wird der String-Rohwert des jeweils gewählten Zeitraums.
                    Text(timeframe.rawValue)
                }
            }
            // Die Darstellung als Segment-Control spart Platz und passt zum schnellen Umschalten.
            .pickerStyle(.segmented)

            // Das Chart liest je nach Segment-Auswahl Wochen- oder Monatsdaten aus AppData.
            Chart(currentData) { entry in
                // Jeder SavingEntry wird als eigener Balken im Chart dargestellt.
                BarMark(
                    // Auf der X-Achse steht der Zeitraum, also Monat oder Kalenderwoche.
                    x: .value("Zeitraum", entry.month),
                    // Auf der Y-Achse steht der bis dahin erreichte Sparbetrag.
                    y: .value("Gespart", entry.amount)
                )
                // Die Balken übernehmen den grünen Hauptfarbton der App.
                .foregroundStyle(AppColors.primaryGreen)
                // Leicht gerundete Ecken machen die Balken weicher und moderner.
                .cornerRadius(6)
            }
            // Feste Höhe, damit das Diagramm unabhängig von den Daten stabil aussieht.
            .frame(height: 220)

            // Unter dem Diagramm stehen zwei kompakte Kennzahlenkarten.
            VStack(spacing: 10) {
                // Erste Karte: alle bisher erfassten Ausgaben als Summe.
                InfoCard(title: "Erfasste Ausgaben", value: appData.formatCurrency(appData.totalExpenses))
                // Zweite Karte: der Restbetrag bis zum aktuell gesetzten Sparziel.
                InfoCard(title: "Noch bis zum Ziel", value: appData.formatCurrency(appData.remainingToGoal))
            }
            // Kleiner Abstand zwischen Diagramm und Kennzahlenkarten.
            .padding(.top, 10)

            // Der Spacer schiebt den Inhalt nach oben und hält unten Luft auf größeren Displays.
            Spacer()
        }
        // Außenabstand für den gesamten Screen-Inhalt.
        .padding()
        // Leichter grüner Hintergrund passend zur restlichen App.
        .background(AppColors.lightBackground)
        .onAppear {
            // Dieser Screen bestätigt dem Tutorial, dass die Statistik-Seite erreicht wurde.
            tutorial.completeNavigation(from: .homeStatsButton, to: .settingsStatsDetails)
        }
        .onChange(of: tutorial.shouldReturnToHome) { _, shouldReturnToHome in
            // Sobald das Tutorial zurück nach Home wechseln will, wird diese View geschlossen.
            if shouldReturnToHome {
                dismiss()
            }
        }
        // Aus der Statistik kann das Tutorial direkt weiter in die Erinnerungen navigieren.
        .navigationDestination(isPresented: $tutorial.navigateToReminders) {
            // Die Erinnerung kann im Tutorial direkt aus der Statistik heraus geöffnet werden.
            ReminderView()
        }
        // Das Spotlight-Overlay wird über die gesamte Statistikansicht gelegt, wenn das Tutorial aktiv ist.
        .tutorialSpotlightHost()
    }
}

extension SavingsGoalView {
    // Diese Hilfseigenschaft kapselt die Auswahl zwischen Wochen- und Monatsdaten für das Chart.
    private var currentData: [SavingEntry] {
        // Je nach Picker-Auswahl werden unterschiedliche vorberechnete Reihen aus AppData verwendet.
        selectedTimeframe == .months ? appData.monthlySavingsEntries() : appData.weeklySavingsEntries()
    }
}

// Die Info-Karten ergänzen die Grafik um zwei zentrale Kennzahlen ohne zusätzliche Screenwechsel.
private struct InfoCard: View {
    // Linke Beschriftung der Kennzahl.
    let title: String
    // Rechter Wert der Kennzahl, bereits als String vorbereitet.
    let value: String

    var body: some View {
        // Titel links, Wert rechts in einer Zeile.
        HStack {
            // Der Titel ist bewusst dezenter gestaltet als der Zahlenwert.
            Text(title)
                .foregroundStyle(.gray)

            // Spacer trennt Label und Wert sauber voneinander.
            Spacer()

            // Der Wert wird stärker gewichtet, damit er schneller auffällt.
            Text(value)
                .fontWeight(.semibold)
        }
        // Innenabstand gibt der Karte Luft.
        .padding()
        // Transparenter Hintergrund passt zum restlichen Statistik-Look.
        .background(Color.white.opacity(0.3))
        // Abgerundete Ecken lassen die Karte wie einen eigenen UI-Block wirken.
        .cornerRadius(18)
    }
}

#Preview {
    // Vorschau mit Beispiel-Datenmodell und Tutorial-Controller für Xcode Canvas.
    SavingsGoalView()
        .environmentObject(AppData())
        .environmentObject(AppTutorialController())
}
