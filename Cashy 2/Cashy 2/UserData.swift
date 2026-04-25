import Foundation
import Combine
import SwiftUI
import UIKit

// Die Grundmodelle beschreiben Ausgaben, Kategorien und Sparfortschritt,
// die später in den Views angezeigt und lokal persistiert werden.
struct Expense: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var date: Date

    init(id: UUID = UUID(), name: String, amount: Double, date: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.date = date
    }
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

struct SavingsUpdate: Identifiable, Codable {
    let id: UUID
    let previousAmount: Double
    let newAmount: Double
    let date: Date

    init(
        id: UUID = UUID(),
        previousAmount: Double,
        newAmount: Double,
        date: Date = Date()
    ) {
        self.id = id
        self.previousAmount = previousAmount
        self.newAmount = newAmount
        self.date = date
    }

    var difference: Double {
        newAmount - previousAmount
    }
}

struct TimelineActivity: Identifiable {
    let id: UUID
    let title: String
    let detail: String
    let amount: Double
    let date: Date

    var isPositive: Bool {
        amount >= 0
    }
}

private struct ComparisonReference {
    let singular: String
    let plural: String
    let unitCost: Double
}

private struct StoredAccount: Codable {
    let email: String
    let password: String
}

private struct StoredColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double

    init(color: Color) {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &opacity) {
            self.red = Double(red)
            self.green = Double(green)
            self.blue = Double(blue)
            self.opacity = Double(opacity)
            return
        }

        var white: CGFloat = 0
        if uiColor.getWhite(&white, alpha: &opacity) {
            self.red = Double(white)
            self.green = Double(white)
            self.blue = Double(white)
            self.opacity = Double(opacity)
            return
        }

        self.red = 0.5
        self.green = 0.5
        self.blue = 0.5
        self.opacity = 1
    }

    var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

private struct StoredCategory: Codable {
    let name: String
    let color: StoredColor
    let expenses: [Expense]
}

private struct StoredAppState: Codable {
    let selectedCurrencyName: String
    let selectedCurrencyCode: String
    let savingsGoal: Double
    let savedAmount: Double
    let badHabitAnswer: String
    let savingsUpdates: [SavingsUpdate]
    let categories: [StoredCategory]
    let hasCompletedOnboarding: Bool
    let hasSeenAppTutorial: Bool

    enum CodingKeys: String, CodingKey {
        case selectedCurrencyName
        case selectedCurrencyCode
        case savingsGoal
        case savedAmount
        case badHabitAnswer
        case savingsUpdates
        case categories
        case hasCompletedOnboarding
        case hasSeenAppTutorial
    }

    init(
        selectedCurrencyName: String,
        selectedCurrencyCode: String,
        savingsGoal: Double,
        savedAmount: Double,
        badHabitAnswer: String,
        savingsUpdates: [SavingsUpdate],
        categories: [StoredCategory],
        hasCompletedOnboarding: Bool,
        hasSeenAppTutorial: Bool
    ) {
        self.selectedCurrencyName = selectedCurrencyName
        self.selectedCurrencyCode = selectedCurrencyCode
        self.savingsGoal = savingsGoal
        self.savedAmount = savedAmount
        self.badHabitAnswer = badHabitAnswer
        self.savingsUpdates = savingsUpdates
        self.categories = categories
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasSeenAppTutorial = hasSeenAppTutorial
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedCurrencyName = try container.decode(String.self, forKey: .selectedCurrencyName)
        selectedCurrencyCode = try container.decode(String.self, forKey: .selectedCurrencyCode)
        savingsGoal = try container.decode(Double.self, forKey: .savingsGoal)
        savedAmount = try container.decode(Double.self, forKey: .savedAmount)
        badHabitAnswer = try container.decode(String.self, forKey: .badHabitAnswer)
        savingsUpdates = try container.decode([SavingsUpdate].self, forKey: .savingsUpdates)
        categories = try container.decode([StoredCategory].self, forKey: .categories)
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        hasSeenAppTutorial = try container.decodeIfPresent(Bool.self, forKey: .hasSeenAppTutorial) ?? false
    }
}

// AppData ist die zentrale Datenquelle der App:
// Account-Verwaltung, Onboarding-Zustand, Kategorien, Sparstände und Persistenz laufen hier zusammen.
final class AppData: ObservableObject {
    private static let accountsStorageKey = "cashy_accounts"

    private static let defaultCategories: [Category] = [
        Category(name: "Skincare", color: Color(red: 0.55, green: 0.70, blue: 0.55)),
        Category(name: "Make-Up", color: Color(red: 0.45, green: 0.65, blue: 0.50)),
        Category(name: "Drogen", color: Color(red: 0.40, green: 0.60, blue: 0.45)),
        Category(name: "Snacks", color: Color(red: 0.35, green: 0.50, blue: 0.30)),
        Category(name: "Abos", color: Color(red: 0.55, green: 0.50, blue: 0.35)),
        Category(name: "Kleidung", color: Color(red: 0.50, green: 0.45, blue: 0.30))
    ]

    let objectWillChange = ObservableObjectPublisher()

    private var isRestoringState = false
    private(set) var currentUserEmail: String? {
        willSet { objectWillChange.send() }
    }

    var selectedCurrencyName = "Euro" {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var selectedCurrencyCode = "EUR" {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var savingsGoal: Double = 500 {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var savedAmount: Double = 0 {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var badHabitAnswer = "" {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var savingsUpdates: [SavingsUpdate] = [] {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var hasCompletedOnboarding = false {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var hasSeenAppTutorial = false {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
    }

    var categories: [Category] = AppData.defaultCategories {
        willSet { objectWillChange.send() }
        didSet { persistCurrentUserState() }
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

    // Diese berechneten Werte verdichten Sparziel, Fortschritt und Verlauf für Home und Statistik.
    var currentSavings: Double {
        savedAmount
    }

    var remainingToGoal: Double {
        max(savingsGoal - currentSavings, 0)
    }

    var savingsProgress: Double {
        guard savingsGoal > 0 else { return 0 }
        return min(currentSavings / savingsGoal, 1)
    }

    var isLoggedIn: Bool {
        currentUserEmail != nil
    }

    var timelineActivities: [TimelineActivity] {
        // Ausgaben und Sparupdates werden in eine gemeinsame Timeline überführt,
        // damit Home nur noch eine sortierte Aktivitätsliste rendern muss.
        let expenseActivities = categories.flatMap { category in
            category.expenses.map { expense in
                TimelineActivity(
                    id: expense.id,
                    title: "\(expense.name) · \(category.name)",
                    detail: comparisonText(for: expense.amount),
                    amount: -expense.amount,
                    date: expense.date
                )
            }
        }

        let savingsActivities = savingsUpdates.map { update in
            let detail = "Gesamt gespart: \(formatCurrency(update.newAmount))"
            return TimelineActivity(
                id: update.id,
                title: "Zusätzlich gespart",
                detail: detail,
                amount: update.difference,
                date: update.date
            )
        }

        return (expenseActivities + savingsActivities)
            .sorted { $0.date > $1.date }
    }

    func updateCurrency(name: String, code: String) {
        selectedCurrencyName = name
        selectedCurrencyCode = code
    }

    // Registrierung und Login arbeiten mit einfachen lokal gespeicherten Accounts,
    // damit jede E-Mail ihren eigenen separaten App-Zustand bekommt.
    func registerAccount(email: String, password: String) -> Bool {
        let normalizedEmail = normalizeEmail(email)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty, !trimmedPassword.isEmpty else { return false }

        var accounts = loadAccounts()
        guard !accounts.contains(where: { $0.email == normalizedEmail }) else { return false }

        accounts.append(StoredAccount(email: normalizedEmail, password: trimmedPassword))
        saveAccounts(accounts)
        saveAppState(defaultStoredAppState(), for: normalizedEmail)
        return true
    }

    func login(email: String, password: String) -> Bool {
        let normalizedEmail = normalizeEmail(email)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let account = loadAccounts().first(where: { $0.email == normalizedEmail }),
              account.password == trimmedPassword else {
            return false
        }

        currentUserEmail = normalizedEmail
        restoreAppState(for: normalizedEmail)
        return true
    }

    func logout() {
        currentUserEmail = nil
        resetToDefaultState()
    }

    func deleteCurrentAccount(password: String) -> Bool {
        guard let currentUserEmail = currentUserEmail else { return false }

        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPassword.isEmpty else { return false }

        var accounts = loadAccounts()
        guard let accountIndex = accounts.firstIndex(where: {
            $0.email == currentUserEmail && $0.password == trimmedPassword
        }) else {
            return false
        }

        accounts.remove(at: accountIndex)
        saveAccounts(accounts)
        UserDefaults.standard.removeObject(forKey: storageKey(for: currentUserEmail))

        self.currentUserEmail = nil
        resetToDefaultState()
        return true
    }

    func updateSavingsGoal(_ newGoal: Double) {
        guard newGoal > 0 else { return }
        savingsGoal = newGoal
    }

    // Neue Sparbeträge werden als Verlaufseintrag gespeichert,
    // damit Statistik und Timeline nicht nur den Endstand kennen.
    func addSavedAmount(_ addedAmount: Double) {
        guard addedAmount > 0 else { return }
        let previousAmount = savedAmount
        let newAmount = previousAmount + addedAmount
        savedAmount = newAmount
        savingsUpdates.insert(
            SavingsUpdate(previousAmount: previousAmount, newAmount: newAmount),
            at: 0
        )
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func markAppTutorialSeen() {
        hasSeenAppTutorial = true
    }

    func clearHistoryAndStats() {
        // Diese Funktion leert finanzielle Verlaufsdaten, belässt aber die vorhandenen Kategorien.
        savedAmount = 0
        savingsUpdates = []
        categories = categories.map { category in
            Category(name: category.name, color: category.color, expenses: [])
        }
    }

    func saveBadHabit(_ text: String) {
        // Die Onboarding-Antwort wird gespeichert und kann gleichzeitig automatisch
        // eine passende Kategorie erzeugen, falls sie noch nicht existiert.
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
        // Neue Kategorien erhalten rotierend Farben aus einer kleinen Palette,
        // damit die Karten und Diagramme visuell unterscheidbar bleiben.
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
        // Die Währungsausgabe richtet sich nach der im Onboarding oder Konto gewählten Währung.
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
        // Für die Statistik werden historische Sparstände bis zum Ende jedes Monats aggregiert.
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

            let periodSavedAmount = savedAmountValue(until: nextMonthStart)
            return SavingEntry(month: monthFormatter.string(from: monthStart).capitalized, amount: periodSavedAmount)
        }
    }

    func weeklySavingsEntries() -> [SavingEntry] {
        // Dieselbe Logik wird auch auf Wochenbasis angeboten, damit der Nutzer zwischen beiden Sichten wechseln kann.
        let calendar = Calendar.current
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else {
            return [SavingEntry(month: "Diese Woche", amount: currentSavings)]
        }

        return (0..<4).compactMap { index in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: index - 3, to: currentWeekStart),
                  let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else {
                return nil
            }

            let periodSavedAmount = savedAmountValue(until: nextWeekStart)
            let weekNumber = calendar.component(.weekOfYear, from: weekStart)
            return SavingEntry(month: "KW \(weekNumber)", amount: periodSavedAmount)
        }
    }

    func comparisonText(for amount: Double) -> String {
        // Ausgaben werden in bekannte Alltagsvergleiche übersetzt,
        // um Beträge emotional greifbarer zu machen.
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

    private func savedAmountValue(until date: Date) -> Double {
        savingsUpdates
            .filter { $0.date < date }
            .sorted { $0.date < $1.date }
            .last?
            .newAmount ?? 0
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

    private func persistCurrentUserState() {
        // Jede relevante Änderung wird sofort dem aktuell eingeloggten Nutzer zugeordnet gespeichert.
        guard !isRestoringState, let currentUserEmail = currentUserEmail else { return }
        saveAppState(makeStoredAppState(), for: currentUserEmail)
    }

    private func resetToDefaultState() {
        // Beim Logout wird ein frischer Standardzustand geladen,
        // ohne dabei versehentlich wieder etwas in den gerade verlassenen Account zu schreiben.
        isRestoringState = true
        defer { isRestoringState = false }

        let defaultState = defaultStoredAppState()
        selectedCurrencyName = defaultState.selectedCurrencyName
        selectedCurrencyCode = defaultState.selectedCurrencyCode
        savingsGoal = defaultState.savingsGoal
        savedAmount = defaultState.savedAmount
        badHabitAnswer = defaultState.badHabitAnswer
        savingsUpdates = defaultState.savingsUpdates
        categories = defaultState.categories.map { storedCategory in
            Category(
                name: storedCategory.name,
                color: storedCategory.color.swiftUIColor,
                expenses: storedCategory.expenses
            )
        }
        hasCompletedOnboarding = defaultState.hasCompletedOnboarding
        hasSeenAppTutorial = defaultState.hasSeenAppTutorial
    }

    private func restoreAppState(for email: String) {
        // Beim Login wird der gesamte gespeicherte Nutzerzustand zurück in SwiftUI-Strukturen übersetzt.
        isRestoringState = true
        defer { isRestoringState = false }

        let storedState = loadAppState(for: email) ?? defaultStoredAppState()
        selectedCurrencyName = storedState.selectedCurrencyName
        selectedCurrencyCode = storedState.selectedCurrencyCode
        savingsGoal = storedState.savingsGoal
        savedAmount = storedState.savedAmount
        badHabitAnswer = storedState.badHabitAnswer
        savingsUpdates = storedState.savingsUpdates
        categories = storedState.categories.map { storedCategory in
            Category(
                name: storedCategory.name,
                color: storedCategory.color.swiftUIColor,
                expenses: storedCategory.expenses
            )
        }
        hasCompletedOnboarding = storedState.hasCompletedOnboarding
        hasSeenAppTutorial = storedState.hasSeenAppTutorial
    }

    private func makeStoredAppState() -> StoredAppState {
        StoredAppState(
            selectedCurrencyName: selectedCurrencyName,
            selectedCurrencyCode: selectedCurrencyCode,
            savingsGoal: savingsGoal,
            savedAmount: savedAmount,
            badHabitAnswer: badHabitAnswer,
            savingsUpdates: savingsUpdates,
            categories: categories.map {
                StoredCategory(
                    name: $0.name,
                    color: StoredColor(color: $0.color),
                    expenses: $0.expenses
                )
            },
            hasCompletedOnboarding: hasCompletedOnboarding,
            hasSeenAppTutorial: hasSeenAppTutorial
        )
    }

    private func defaultStoredAppState() -> StoredAppState {
        StoredAppState(
            selectedCurrencyName: "Euro",
            selectedCurrencyCode: "EUR",
            savingsGoal: 500,
            savedAmount: 0,
            badHabitAnswer: "",
            savingsUpdates: [],
            categories: AppData.defaultCategories.map {
                StoredCategory(
                    name: $0.name,
                    color: StoredColor(color: $0.color),
                    expenses: $0.expenses
                )
            },
            hasCompletedOnboarding: false,
            hasSeenAppTutorial: false
        )
    }

    private func loadAccounts() -> [StoredAccount] {
        guard let data = UserDefaults.standard.data(forKey: AppData.accountsStorageKey),
              let accounts = try? JSONDecoder().decode([StoredAccount].self, from: data) else {
            return []
        }
        return accounts
    }

    private func saveAccounts(_ accounts: [StoredAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        UserDefaults.standard.set(data, forKey: AppData.accountsStorageKey)
    }

    private func loadAppState(for email: String) -> StoredAppState? {
        guard let data = UserDefaults.standard.data(forKey: storageKey(for: email)),
              let state = try? JSONDecoder().decode(StoredAppState.self, from: data) else {
            return nil
        }
        return state
    }

    private func saveAppState(_ state: StoredAppState, for email: String) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey(for: email))
    }

    private func storageKey(for email: String) -> String {
        "cashy_state_\(email)"
    }

    private func normalizeEmail(_ email: String) -> String {
        // Mails werden normalisiert, damit Login und Registrierung dieselbe Schreibweise vergleichen.
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
