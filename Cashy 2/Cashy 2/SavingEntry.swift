import Foundation

struct SavingEntry: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}
