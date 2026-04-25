import SwiftUI
import Charts

struct SavingsGoalView: View {
    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var tutorial: AppTutorialController
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTimeframe: Timeframe = .months

    enum Timeframe: String, CaseIterable {
        case months = "Monate"
        case weeks = "Wochen"
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Sparziel")
                    .font(.largeTitle)
                    .bold()

                Spacer()

                Text(appData.formatCurrency(appData.savingsGoal))
                    .font(.title2)
                    .bold()
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Bereits gespart")
                    .font(.headline)

                Text(appData.formatCurrency(appData.currentSavings))
                    .font(.title)
                    .fontWeight(.bold)

                ProgressView(value: appData.savingsProgress)
                    .tint(AppColors.primaryGreen)
                    .scaleEffect(x: 1, y: 2, anchor: .center)

                Text("Der Balken und das Diagramm orientieren sich an deinem eingetragenen Sparstand.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            .padding()
            .background(Color.white.opacity(0.35))
            .cornerRadius(20)
            .tutorialTarget(.settingsStatsDetails)

            Picker("Zeitraum", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Chart(currentData) { entry in
                BarMark(
                    x: .value("Zeitraum", entry.month),
                    y: .value("Gespart", entry.amount)
                )
                .foregroundStyle(AppColors.primaryGreen)
                .cornerRadius(6)
            }
            .frame(height: 220)

            VStack(spacing: 10) {
                InfoCard(title: "Erfasste Ausgaben", value: appData.formatCurrency(appData.totalExpenses))
                InfoCard(title: "Noch bis zum Ziel", value: appData.formatCurrency(appData.remainingToGoal))
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding()
        .background(AppColors.lightBackground)
        .onAppear {
            tutorial.completeNavigation(from: .homeStatsButton, to: .settingsStatsDetails)
        }
        .onChange(of: tutorial.shouldReturnToHome) { _, shouldReturnToHome in
            if shouldReturnToHome {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $tutorial.navigateToReminders) {
            ReminderView()
        }
        .tutorialSpotlightHost()
    }
}

extension SavingsGoalView {
    private var currentData: [SavingEntry] {
        selectedTimeframe == .months ? appData.monthlySavingsEntries() : appData.weeklySavingsEntries()
    }
}

private struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.gray)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(18)
    }
}

#Preview {
    SavingsGoalView()
        .environmentObject(AppData())
        .environmentObject(AppTutorialController())
}
