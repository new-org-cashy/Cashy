import SwiftUI
import Charts

struct SavingsGoalView: View {
    
    @State private var selectedTimeframe: Timeframe = .months
    
    enum Timeframe: String, CaseIterable {
        case months = "Monate"
        case weeks = "Wochen"
    }
    
    // Beispiel Daten
    @State private var monthlySavings: [SavingEntry] = [
        SavingEntry(month: "Jan", amount: 80),
        SavingEntry(month: "Feb", amount: 100),
        SavingEntry(month: "Mär", amount: 150),
        SavingEntry(month: "Apr", amount: 120),
        SavingEntry(month: "Mai", amount: 160),
        SavingEntry(month: "Jun", amount: 180)
    ]
    
    @State private var weeklySavings: [SavingEntry] = [
        SavingEntry(month: "W1", amount: 25),
        SavingEntry(month: "W2", amount: 40),
        SavingEntry(month: "W3", amount: 30),
        SavingEntry(month: "W4", amount: 45)
    ]
    
    let savingsGoal: Double = 500
    
    var body: some View {
        VStack(spacing: 18) {
            
            // MARK: Titel
            HStack {
                Text("Sparziel")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Text("\(Int(savingsGoal))€")
                    .font(.title)
                    .bold()
            }
            
            // MARK: Toggle
            Picker("Zeitraum", selection: $selectedTimeframe) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Text(timeframe.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            Spacer(minLength: 10)
            
            // MARK: Chart
            Chart(currentData) { entry in
                BarMark(
                    x: .value("Zeitraum", entry.month),
                    y: .value("Betrag", entry.amount)
                )
                .foregroundStyle(AppColors.primaryGreen)
                .cornerRadius(6)
            }
            .frame(height: 220)
            
            // MARK: Prognose
            VStack(spacing: 10) {
                
                Text("Wenn du durchschnittlich \(Int(averageSaving))€ pro \(selectedTimeframe == .months ? "Monat" : "Woche") sparst, erreichst du dein Ziel in \(timeToGoal) \(selectedTimeframe == .months ? "Monaten" : "Wochen").")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(20)
                
                Text("💡 Wenn du etwa \(Int(extraMoneySuggestion))€ mehr pro \(selectedTimeframe == .months ? "Monat" : "Woche") sparen würdest, könntest du dein Ziel schon in \(fasterTimeToGoal) \(selectedTimeframe == .months ? "Monaten" : "Wochen") erreichen.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.horizontal)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
        .background(AppColors.lightBackground)
    }
}

// MARK: - Berechnungen
extension SavingsGoalView {
    
    private var currentData: [SavingEntry] {
        selectedTimeframe == .months ? monthlySavings : weeklySavings
    }
    
    private var totalSaved: Double {
        currentData.map { $0.amount }.reduce(0, +)
    }
    
    private var averageSaving: Double {
        totalSaved / Double(currentData.count)
    }
    
    private var timeToGoal: Int {
        let remaining = savingsGoal - totalSaved
        if remaining <= 0 { return 0 }
        return Int(ceil(remaining / averageSaving))
    }
    
    // Wir schlagen 30€ extra vor (realistisch & verständlich)
    private var extraMoneySuggestion: Double {
        selectedTimeframe == .months ? 30 : 10
    }
    
    private var fasterTimeToGoal: Int {
        let remaining = savingsGoal - totalSaved
        let newAverage = averageSaving + extraMoneySuggestion
        
        if remaining <= 0 { return 0 }
        return Int(ceil(remaining / newAverage))
    }
}

// MARK: Preview
#Preview {
    SavingsGoalView()
}
