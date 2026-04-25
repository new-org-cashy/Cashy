import SwiftUI

// Home bündelt den aktuellen Sparstand, das Ziel, den Verlauf und die Hauptnavigation der App.
struct ZielView: View { var body: some View { Text("Hier geht es zu den Ausgaben").font(.title).foregroundColor(.green) } }
struct PersonView: View { var body: some View { Text("Person View").font(.title) } }
struct CartView: View { var body: some View { Text("Warenkorb View").font(.title) } }
struct settingsView: View { var body: some View { Text("Einstellungen View").font(.title) } }
struct VirtuelleWeltView: View { var body: some View { Text("Virtuelle Welt").font(.title) } }

struct ActivityRow: View {
    let title: String
    let detail: String
    let amount: String
    let amountColor: Color

    var body: some View {
        // Jede Aktivität zeigt Titel, Zusatzinfo und Betrag in einer kompakten Timeline-Zeile.
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)

                if !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text(amount)
                .foregroundColor(amountColor)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
    }
}

struct LavaLampBackground: View {
    @State private var start = UnitPoint.top
    @State private var end = UnitPoint.bottom

    var body: some View {
        // Der animierte Verlauf gibt Home mehr Bewegung, ohne den eigentlichen Content zu überlagern.
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.3),
                Color.green.opacity(0.1),
                Color.green.opacity(0.25)
            ]),
            startPoint: start,
            endPoint: end
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: true)) {
                start = UnitPoint.bottomLeading
                end = UnitPoint.topTrailing
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var tutorial: AppTutorialController

    @State private var pressedVirtuelle = false
    @State private var pressedAusgaben = false
    @State private var pressedPerson = false
    @State private var pressedCart = false
    @State private var pressedSettings = false
    @State private var showGoalSheet = false
    @State private var goalDraft = ""
    @State private var showSavedAmountSheet = false
    @State private var savedAmountDraft = ""

    var body: some View {
        ZStack {
            LavaLampBackground()

            VStack(spacing: 20) {
                // Im oberen Bereich liegen Titel und direkter Einstieg in die Ausgabenansicht.
                HStack(spacing: 12) {
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

                    NavigationLink(destination: ContentView()) {
                        Text("Ausgaben")
                            .foregroundColor(.black)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(Color.gray.opacity(0.25))
                            .cornerRadius(12)
                            .scaleEffect(pressedVirtuelle ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: pressedVirtuelle)
                    }
                    .tutorialTarget(.homeExpensesButton)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in pressedVirtuelle = true }
                            .onEnded { _ in pressedVirtuelle = false }
                    )

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 25) {
                    // Diese Karte zeigt Sparstand und Ziel auf einen Blick
                    // und öffnet über Tap die zugehörigen Eingabesheets.
                    Text("Bereits gespart:")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Button {
                        savedAmountDraft = ""
                        showSavedAmountSheet = true
                    } label: {
                        Text(appData.formatCurrency(appData.currentSavings))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .buttonStyle(.plain)
                    .tutorialTarget(.homeSavings)

                    ProgressView(value: appData.savingsProgress)
                        .tint(.green)
                        .scaleEffect(x: 1, y: 2, anchor: .center)

                    Text("\(appData.formatCurrency(appData.currentSavings)) von \(appData.formatCurrency(appData.savingsGoal))")
                        .font(.caption)
                        .foregroundColor(.gray)

                    HStack(alignment: .center) {
                        Button {
                            goalDraft = formattedGoalInput(appData.savingsGoal)
                            showGoalSheet = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Dein Ziel")
                                    .font(.subheadline)
                                    .foregroundColor(.black)

                                Text(appData.formatCurrency(appData.savingsGoal))
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(.plain)
                        .tutorialTarget(.homeGoal)

                        Spacer()

                        
                    }
                }
                .padding()
                .padding(.bottom, 18)
                .background(Color.green.opacity(0.22))
                .cornerRadius(22)
                .padding(.horizontal)

                ScrollView {
                    // Der Verlauf kombiniert Sparupdates und Ausgaben chronologisch,
                    // damit der Nutzer seine letzten Änderungen schnell nachvollziehen kann.
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Verlauf")
                            .font(.headline)
                            .padding(.horizontal)

                        if appData.timelineActivities.isEmpty {
                            Text("Noch kein Sparstand oder Ausgaben eingetragen.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(Array(appData.timelineActivities.prefix(12).enumerated()), id: \.element.id) { index, activity in
                                    ActivityRow(
                                        title: activity.title,
                                        detail: activity.detail,
                                        amount: formattedTimelineAmount(activity.amount),
                                        amountColor: activity.isPositive ? .green : .red
                                    )

                                    if index < min(appData.timelineActivities.count, 12) - 1 {
                                        Divider()
                                            .background(Color.gray.opacity(0.15))
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 260, alignment: .topLeading)
                }
                .padding()
                .background(Color.green.opacity(0.18))
                .cornerRadius(22)
                .padding(.horizontal)
                .tutorialTarget(.homeHistory)

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showGoalSheet) {
            GoalEditSheet(goalDraft: $goalDraft)
        }
        .sheet(isPresented: $showSavedAmountSheet) {
            SavedAmountSheet(savedAmountDraft: $savedAmountDraft)
        }
        // Diese Ziele werden nicht nur manuell geöffnet, sondern auch vom Tutorial angesteuert.
        .navigationDestination(isPresented: $tutorial.navigateToExpenses) {
            ContentView()
        }
        .navigationDestination(isPresented: $tutorial.navigateToStats) {
            SavingsGoalView()
        }
        .navigationDestination(isPresented: $tutorial.navigateToReminders) {
            ReminderView()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 5) {
                Divider()
                    .background(Color.gray.opacity(0.3))

                HStack {
                    NavigationLink(destination: ReminderView()) {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                            .scaleEffect(pressedPerson ? 0.9 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: pressedPerson)
                    }
                    .tutorialTarget(.homeReminderButton)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in pressedPerson = true }
                            .onEnded { _ in pressedPerson = false }
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink(destination: SavingsGoalView()) {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.black)
                            .scaleEffect(pressedCart ? 0.9 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: pressedCart)
                    }
                    .tutorialTarget(.homeStatsButton)
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
        .onAppear {
            // Wenn das Tutorial von einer Unterseite nach Home zurückkehrt,
            // wird hier zuerst der wartende Home-Schritt reaktiviert und danach ggf. das Erst-Tutorial gestartet.
            tutorial.completeHomeReturnIfNeeded()
            tutorial.startIfNeeded(appData: appData)
        }
        .tutorialSpotlightHost()
    }

    private func formattedGoalInput(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(value)
    }

    private func formattedTimelineAmount(_ value: Double) -> String {
        if value >= 0 {
            return "+\(appData.formatCurrency(value))"
        }
        return "-\(appData.formatCurrency(abs(value)))"
    }
}

struct GoalEditSheet: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @Binding var goalDraft: String

    var body: some View {
        NavigationStack {
            // Dieses Sheet ändert nur das Sparziel und gibt die Daten direkt an AppData weiter.
            VStack(alignment: .leading, spacing: 20) {
                Text("Neues Sparziel")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField("Betrag eingeben", text: $goalDraft)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                Text("Das neue Ziel wird nach deiner Bestätigung direkt auf Home und in den Statistiken übernommen.")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Bestätigen") {
                        let normalizedGoal = goalDraft.replacingOccurrences(of: ",", with: ".")
                        if let goalValue = Double(normalizedGoal) {
                            appData.updateSavingsGoal(goalValue)
                        }
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct SavedAmountSheet: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @Binding var savedAmountDraft: String

    var body: some View {
        NavigationStack {
            // Hier trägt der Nutzer zusätzliche Sparbeträge ein,
            // die anschließend auf den bisherigen Stand addiert werden.
            VStack(alignment: .leading, spacing: 20) {
                Text("Zusätzlich gesparten Betrag eintragen")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Aktuell gespart: \(appData.formatCurrency(appData.currentSavings))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                TextField("Wie viel hast du extra gespart?", text: $savedAmountDraft)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                Text("Dieser Betrag wird auf den bisherigen Sparstand addiert und danach auf Home, im Verlauf und in den Statistiken angezeigt.")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let normalizedAmount = savedAmountDraft.replacingOccurrences(of: ",", with: ".")
                        if let newAmount = Double(normalizedAmount) {
                            appData.addSavedAmount(newAmount)
                        }
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AppData())
            .environmentObject(AppTutorialController())
    }
}
