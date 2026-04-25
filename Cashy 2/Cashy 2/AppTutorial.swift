import Combine
import SwiftUI

enum TutorialHighlightTarget: Hashable {
    case homeSavings
    case homeGoal
    case homeHistory
    case homeExpensesButton
    case expenseCategories
    case expenseViewButton
    case expenseChart
    case homeStatsButton
    case homeReminderButton
    case settingsStatsDetails
    case reminderOptions
}

enum AppTutorialStep: Int, CaseIterable, Identifiable {
    case homeSavings
    case homeGoal
    case homeHistory
    case homeExpensesButton
    case expenseCategories
    case expenseViewButton
    case expenseChart
    case homeStatsButton
    case homeReminderButton
    case settingsStatsDetails
    case reminderOptions

    var id: Int { rawValue }

    var target: TutorialHighlightTarget {
        switch self {
        case .homeSavings:
            return .homeSavings
        case .homeGoal:
            return .homeGoal
        case .homeHistory:
            return .homeHistory
        case .homeExpensesButton:
            return .homeExpensesButton
        case .homeStatsButton:
            return .homeStatsButton
        case .homeReminderButton:
            return .homeReminderButton
        case .expenseCategories:
            return .expenseCategories
        case .expenseViewButton:
            return .expenseViewButton
        case .expenseChart:
            return .expenseChart
        case .settingsStatsDetails:
            return .settingsStatsDetails
        case .reminderOptions:
            return .reminderOptions
        }
    }

    var title: String {
        switch self {
        case .homeSavings:
            return "Dein Sparbetrag"
        case .homeGoal:
            return "Sparziel anpassen"
        case .homeHistory:
            return "Dein Verlauf"
        case .homeExpensesButton:
            return "Zu deinen Ausgaben"
        case .homeStatsButton:
            return "Zu deinen Statistiken"
        case .homeReminderButton:
            return "Zu deinen Erinnerungen"
        case .expenseCategories:
            return "Kategorien und Ausgaben"
        case .expenseViewButton:
            return "Ausgaben als Ansicht"
        case .expenseChart:
            return "Diagramm deiner Ausgaben"
        case .settingsStatsDetails:
            return "Was die Statistiken zeigen"
        case .reminderOptions:
            return "Erinnerungen eintragen"
        }
    }

    var message: String {
        switch self {
        case .homeSavings:
            return "Hier siehst du jederzeit, wie viel du bereits gespart hast. Ein Klick darauf öffnet die Eingabe für einen neuen Sparbetrag."
        case .homeGoal:
            return "Hier kannst du dein aktuelles Sparziel ändern. Der neue Wert wird direkt in Home und in den Statistiken übernommen."
        case .homeHistory:
            return "Hier wird dein Verlauf angezeigt: zusätzliche Sparbeträge und eingetragene Ausgaben erscheinen chronologisch in einer Liste."
        case .homeExpensesButton:
            return "Über dieses Symbol wechselst du zu den Kategorien deiner schlechten Angewohnheiten und kannst dort Ausgaben eintragen."
        case .homeStatsButton:
            return "Über das Balken-Symbol unten in der Mitte öffnest du deine Statistik-Seite mit Sparstand, Verlauf und Auswertungen."
        case .homeReminderButton:
            return "Über die Glocke unten links öffnest du deine Erinnerungen. Dort legst du fest, wann Cashy dich ans Sparen erinnern soll."
        case .expenseCategories:
            return "Hier liegen deine Kategorien. Mit dem Plus in einer Kategorie trägst du neue Ausgaben ein. Wenn du einen Kategoriekasten gedrückt hältst, kannst du seinen Namen ändern."
        case .expenseViewButton:
            return "Hier öffnest du die Ansicht deiner Ausgaben als Übersicht und Diagramm."
        case .expenseChart:
            return "Dieses Diagramm zeigt dir, wie sich deine Ausgaben auf die Kategorien verteilen. Darunter siehst du die wichtigsten Einträge je Kategorie."
        case .settingsStatsDetails:
            return "Hier siehst du dein Sparziel, deinen bisherigen Sparstand, den Fortschrittsbalken und Diagramme für Wochen oder Monate. Die Karten darunter zeigen deine erfassten Ausgaben und wie viel noch bis zum Ziel fehlt."
        case .reminderOptions:
            return "Hier legst du fest, wann Cashy dich erinnern soll. Die Erinnerungen helfen dir, regelmäßig Sparbeträge einzutragen und dein Ziel nicht aus dem Blick zu verlieren."
        }
    }

    var primaryActionTitle: String {
        switch self {
        case .homeExpensesButton:
            return "Zu den Ausgaben"
        case .homeStatsButton:
            return "Statistiken öffnen"
        case .homeReminderButton:
            return "Erinnerungen öffnen"
        case .expenseViewButton:
            return "Zum Diagramm"
        case .expenseChart:
            return "Zur Statistik"
        case .reminderOptions:
            return "Fertig"
        default:
            return "Weiter"
        }
    }

    var spotlightPadding: CGFloat {
        switch self {
        case .homeExpensesButton, .homeStatsButton, .homeReminderButton:
            return 18
        case .expenseChart, .settingsStatsDetails, .reminderOptions:
            return 12
        default:
            return 10
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .homeSavings, .homeGoal, .homeHistory, .expenseCategories, .expenseChart,
             .settingsStatsDetails, .reminderOptions:
            return 26
        case .homeExpensesButton, .homeStatsButton, .homeReminderButton, .expenseViewButton:
            return 22
        }
    }

    var prefersTopCardPlacement: Bool {
        switch self {
        case .homeStatsButton, .homeReminderButton:
            return true
        default:
            return false
        }
    }
}

@MainActor
final class AppTutorialController: ObservableObject {
    @Published private(set) var currentStep: AppTutorialStep = .homeSavings
    @Published private(set) var isActive = false

    @Published var navigateToExpenses = false
    @Published var navigateToExpenseChart = false
    @Published var navigateToStats = false
    @Published var navigateToReminders = false
    @Published var shouldReturnToHome = false

    private var pendingHomeStep: AppTutorialStep?

    var progressText: String {
        "\(currentStep.rawValue + 1) / \(AppTutorialStep.allCases.count)"
    }

    func startIfNeeded(appData: AppData) {
        guard appData.isLoggedIn,
              appData.hasCompletedOnboarding,
              !appData.hasSeenAppTutorial,
              !isActive else {
            return
        }

        resetNavigation()
        currentStep = .homeSavings
        isActive = true
    }

    func advance(appData: AppData) {
        guard isActive else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            switch currentStep {
            case .homeSavings:
                currentStep = .homeGoal
            case .homeGoal:
                currentStep = .homeHistory
            case .homeHistory:
                currentStep = .homeExpensesButton
            case .homeExpensesButton:
                navigateToExpenses = true
            case .expenseCategories:
                currentStep = .expenseViewButton
            case .expenseViewButton:
                navigateToExpenseChart = true
            case .expenseChart:
                pendingHomeStep = .homeStatsButton
                shouldReturnToHome = true
            case .homeStatsButton:
                navigateToStats = true
            case .homeReminderButton:
                navigateToReminders = true
            case .settingsStatsDetails:
                pendingHomeStep = .homeReminderButton
                shouldReturnToHome = true
            case .reminderOptions:
                finish(appData: appData)
            }
        }
    }

    func skip(appData: AppData) {
        finish(appData: appData)
    }

    func restart() {
        resetNavigation()
        currentStep = .homeSavings
        isActive = true
    }

    func reset() {
        isActive = false
        currentStep = .homeSavings
        resetNavigation()
    }

    func completeNavigation(from sourceStep: AppTutorialStep, to destinationStep: AppTutorialStep) {
        guard isActive, currentStep == sourceStep else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = destinationStep
        }
    }

    func completeHomeReturnIfNeeded() {
        guard isActive,
              shouldReturnToHome,
              let pendingHomeStep else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = pendingHomeStep
        }

        shouldReturnToHome = false
        self.pendingHomeStep = nil
    }

    private func finish(appData: AppData) {
        appData.markAppTutorialSeen()
        reset()
    }

    private func resetNavigation() {
        navigateToExpenses = false
        navigateToExpenseChart = false
        navigateToStats = false
        navigateToReminders = false
        shouldReturnToHome = false
        pendingHomeStep = nil
    }
}
