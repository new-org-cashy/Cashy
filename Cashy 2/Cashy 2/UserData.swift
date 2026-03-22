import Foundation
import Combine
import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
    var date: Date = Date()
}

struct Category: Identifiable {
    let id = UUID()
    var name: String
    var color: Color
    var expenses: [Expense] = []

    var amount: Double {
        expenses.map { $0.amount }.reduce(0, +)
    }
}

struct ExpenseActivity: Identifiable {
    let id: UUID
    let title: String
    let comparison: String
    let amount: Double
    let date: Date
}

private struct ComparisonReference {
    let singular: String
    let plural: String
    let unitCost: Double
}

final class AppData: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    var selectedCurrencyName = "Euro" {
        willSet { objectWillChange.send() }
    }

    var selectedCurrencyCode = "EUR" {
        willSet { objectWillChange.send() }
    }

    var savingsGoal: Double = 500 {
        willSet { objectWillChange.send() }
    }

    var baselineSavings: Double = 0 {
        willSet { objectWillChange.send() }
    }

    var badHabitAnswer = "" {
        willSet { objectWillChange.send() }
    }

    var categories: [Category] = [
        Category(name: "Skincare", color: Color(red: 0.55, green: 0.70, blue: 0.55)),
        Category(name: "Make-Up", color: Color(red: 0.45, green: 0.65, blue: 0.50)),
        Category(name: "Drogen", color: Color(red: 0.40, green: 0.60, blue: 0.45)),
        Category(name: "Snacks", color: Color(red: 0.35, green: 0.50, blue: 0.30)),
        Category(name: "Abos", color: Color(red: 0.55, green: 0.50, blue: 0.35)),
        Category(name: "Kleidung", color: Color(red: 0.50, green: 0.45, blue: 0.30))
    ] {
        willSet { objectWillChange.send() }
    }

    private let comparisons = [
        ComparisonReference(singular: "Kaffee", plural: "Kaffees", unitCost: 3.5),
        ComparisonReference(singular: "Bubble Tea", plural: "Bubble Teas", unitCost: 6),
        ComparisonReference(singular: "Döner", plural: "Döner", unitCost: 8),
        ComparisonReference(singular: "Kinoticket", plural: "Kinotickets", unitCost: 12),
        ComparisonReference(singular: "Monatsabo", plural: "Monatsabos", unitCost: 15),
        ComparisonReference(singular: "Pizza", plural: "Pizzen", unitCost: 11),
        ComparisonReference(singular: "Sneaker-Paar", plural: "Sneaker-Paare", unitCost: 90)
    ]

    var totalExpenses: Double {
        categories.map { $0.amount }.reduce(0, +)
    }

    var currentSavings: Double {
        max(baselineSavings - totalExpenses, 0)
    }

    var remainingToGoal: Double {
        max(savingsGoal - currentSavings, 0)
    }

    var savingsProgress: Double {
        guard savingsGoal > 0 else { return 0 }
        return min(currentSavings / savingsGoal, 1)
    }

    var expenseActivities: [ExpenseActivity] {
        categories.flatMap { category in
            category.expenses.map { expense in
                ExpenseActivity(
                    id: expense.id,
                    title: "\(expense.name) · \(category.name)",
                    comparison: comparisonText(for: expense.amount),
                    amount: expense.amount,
                    date: expense.date
                )
            }
        }
        .sorted { $0.date > $1.date }
    }

    func updateCurrency(name: String, code: String) {
        selectedCurrencyName = name
        selectedCurrencyCode = code
    }

    func updateSavingsGoal(_ newGoal: Double) {
        guard newGoal > 0 else { return }
        savingsGoal = newGoal
    }

    func saveBadHabit(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        badHabitAnswer = trimmedText

        guard !trimmedText.isEmpty, trimmedText.lowercased() != "keine ahnung" else { return }
        ensureCategory(named: trimmedText)
    }

    func addExpense(name: String, amount: Double, to categoryID: Category.ID) {
        guard amount > 0 else { return }
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else { return }

        let title = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Neue Ausgabe" : name
        let expense = Expense(name: title, amount: amount)
        categories[index].expenses.insert(expense, at: 0)
    }

    func deleteExpense(expenseID: Expense.ID, from categoryID: Category.ID) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        guard let expenseIndex = categories[categoryIndex].expenses.firstIndex(where: { $0.id == expenseID }) else { return }
        categories[categoryIndex].expenses.remove(at: expenseIndex)
    }

    func addCategory(named name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let palette: [Color] = [
            Color(red: 0.43, green: 0.63, blue: 0.47),
            Color(red: 0.60, green: 0.54, blue: 0.33),
            Color(red: 0.33, green: 0.56, blue: 0.39),
            Color(red: 0.53, green: 0.64, blue: 0.51)
        ]

        let color = palette[categories.count % palette.count]
        categories.append(Category(name: trimmedName, color: color))
    }

    func renameCategory(categoryID: Category.ID, to newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard let index = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[index].name = trimmedName
    }

    func deleteCategory(at index: Int) {
        guard categories.indices.contains(index) else { return }
        categories.remove(at: index)
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrencyCode
        formatter.maximumFractionDigits = value.rounded() == value ? 0 : 2
        formatter.locale = Locale.current

        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return formatted
        }

        return "\(Int(value.rounded())) \(selectedCurrencyCode)"
    }

    func formatExpense(_ value: Double) -> String {
        "-\(formatCurrency(value))"
    }

    func monthlySavingsEntries() -> [SavingEntry] {
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "de_DE")
        monthFormatter.dateFormat = "MMM"

        guard let currentMonthStart = calendar.dateInterval(of: .month, for: Date())?.start else {
            return [SavingEntry(month: "Jetzt", amount: currentSavings)]
        }

        return (0..<6).compactMap { index in
            guard let monthStart = calendar.date(byAdding: .month, value: index - 5, to: currentMonthStart),
                  let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                return nil
            }

            let spentUntilPeriodEnd = totalExpenses(until: nextMonthStart)
            let savedAmount = max(baselineSavings - spentUntilPeriodEnd, 0)
            return SavingEntry(month: monthFormatter.string(from: monthStart).capitalized, amount: savedAmount)
        }
    }

    func weeklySavingsEntries() -> [SavingEntry] {
        let calendar = Calendar.current
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return [SavingEntry(month: "Diese Woche", amount: currentSavings)]
        }

        return (0..<4).compactMap { index in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: index - 3, to: currentWeekStart),
                  let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else {
                return nil
            }

            let spentUntilPeriodEnd = totalExpenses(until: nextWeekStart)
            let savedAmount = max(baselineSavings - spentUntilPeriodEnd, 0)
            let weekNumber = calendar.component(.weekOfYear, from: weekStart)
            return SavingEntry(month: "KW \(weekNumber)", amount: savedAmount)
        }
    }

    func comparisonText(for amount: Double) -> String {
        guard amount > 0 else { return "" }

        let ranked = comparisons
            .map { reference -> (ComparisonReference, Double) in
                let rawQuantity = amount / reference.unitCost
                let roundedQuantity = max(1, Int(rawQuantity.rounded()))
                let score = abs(Double(roundedQuantity) - rawQuantity) + abs(2 - Double(roundedQuantity)) * 0.2
                return (reference, score)
            }
            .sorted { $0.1 < $1.1 }

        guard let best = ranked.first?.0 else { return "" }

        let quantity = max(1, Int((amount / best.unitCost).rounded()))
        let label = quantity == 1 ? best.singular : best.plural
        return "Das sind etwa \(quantity) \(label)."
    }

    private func totalExpenses(until date: Date) -> Double {
        categories
            .flatMap { $0.expenses }
            .filter { $0.date < date }
            .map { $0.amount }
            .reduce(0, +)
    }

    private func ensureCategory(named name: String) {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedName.isEmpty else { return }

        let alreadyExists = categories.contains {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalizedName.lowercased()
        }

        guard !alreadyExists else { return }
        addCategory(named: normalizedName)
    }
}
