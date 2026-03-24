import SwiftUI

struct ZielView: View { var body: some View { Text("Hier geht es zu den Ausgaben").font(.title).foregroundColor(.green) } }
struct PersonView: View { var body: some View { Text("Person View").font(.title) } }
struct CartView: View { var body: some View { Text("Warenkorb View").font(.title) } }
struct settingsView: View { var body: some View { Text("Einstellungen View").font(.title) } }
struct VirtuelleWeltView: View { var body: some View { Text("Virtuelle Welt").font(.title) } }

struct ActivityRow: View {
    let title: String
    let comparison: String
    let amount: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)

                if !comparison.isEmpty {
                    Text(comparison)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text(amount)
                .foregroundColor(.red)
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

    @State private var pressedVirtuelle = false
    @State private var pressedAusgaben = false
    @State private var pressedPerson = false
    @State private var pressedCart = false
    @State private var pressedSettings = false
    @State private var showGoalSheet = false
    @State private var goalDraft = ""

    var body: some View {
        ZStack {
            LavaLampBackground()

            VStack(spacing: 20) {
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

                VStack(alignment: .leading, spacing: 25) {
                    Text("Bereits gespart:")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(appData.formatCurrency(appData.currentSavings))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

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

                        Spacer()

                        
                    }
                }
                .padding()
                .padding(.bottom, 18)
                .background(Color.green.opacity(0.22))
                .cornerRadius(22)
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Verlauf")
                            .font(.headline)
                            .padding(.horizontal)

                        if appData.expenseActivities.isEmpty {
                            Text("Noch keine Ausgaben eingetragen.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(Array(appData.expenseActivities.prefix(12).enumerated()), id: \.element.id) { index, activity in
                                    ActivityRow(
                                        title: activity.title,
                                        comparison: activity.comparison,
                                        amount: appData.formatExpense(activity.amount)
                                    )

                                    if index < min(appData.expenseActivities.count, 12) - 1 {
                                        Divider()
                                            .background(Color.gray.opacity(0.15))
                                    }
                                }
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
        .sheet(isPresented: $showGoalSheet) {
            GoalEditSheet(goalDraft: $goalDraft)
        }
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

                    NavigationLink(destination: ContentView()) {
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

    private func formattedGoalInput(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(value)
    }
}

struct GoalEditSheet: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @Binding var goalDraft: String

    var body: some View {
        NavigationStack {
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

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AppData())
    }
}
