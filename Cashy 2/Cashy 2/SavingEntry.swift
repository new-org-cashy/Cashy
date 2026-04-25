import Foundation

// Ein einzelner Statistikpunkt für Wochen- oder Monatsdiagramme.
struct SavingEntry: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}
