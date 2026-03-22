import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @State private var selectedCategoryID: Category.ID?
    @State private var showAddExpense = false
    @State private var showNewCategory = false
    @State private var renameCategoryID: Category.ID?
    @State private var renameDraft = ""
    @State private var showRenamePrompt = false
    @State private var showSecondRenameConfirmation = false

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()

            VStack {
                HStack {
                    NavigationLink(destination: ViewPage()) {
                        HStack(spacing: 10) {
                            Image(systemName: "chart.pie.fill")
                                .font(.title2)
                            Text("Ansicht")
                                .font(.headline)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.orange.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(appData.categories.indices, id: \.self) { index in
                            let category = appData.categories[index]
                            CategoryCard(
                                category: category,
                                currencyFormatter: appData.formatCurrency,
                                onAddExpense: {
                                    selectedCategoryID = category.id
                                    showAddExpense = true
                                },
                                onDelete: {
                                    appData.deleteCategory(at: index)
                                },
                                onRename: {
                                    renameCategoryID = category.id
                                    renameDraft = category.name
                                    showRenamePrompt = true
                                }
                            )
                        }

                        Button {
                            showNewCategory = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Neue Kategorie")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showAddExpense) {
            if let selectedCategoryID = selectedCategoryID {
                AddExpenseView(categoryID: selectedCategoryID)
                    .environmentObject(appData)
            }
        }
        .sheet(isPresented: $showNewCategory) {
            NewCategoryView()
                .environmentObject(appData)
        }
        .alert("Kategorie umbenennen", isPresented: $showRenamePrompt) {
            TextField("Neuer Name", text: $renameDraft)

            Button("Abbrechen", role: .cancel) {
                renameDraft = ""
                renameCategoryID = nil
            }

            Button("1. Bestätigen") {
                showSecondRenameConfirmation = true
            }
        } message: {
            Text("Halte die Kategorie gedrückt, um den Namen zu ändern. Die Änderung wird erst nach einer zweiten Bestätigung gespeichert.")
        }
        .alert("Wirklich umbenennen?", isPresented: $showSecondRenameConfirmation) {
            Button("Nein", role: .cancel) {
                renameDraft = ""
                renameCategoryID = nil
            }

            Button("2. Bestätigen") {
                if let renameCategoryID = renameCategoryID {
                    appData.renameCategory(categoryID: renameCategoryID, to: renameDraft)
                }
                renameDraft = ""
                renameCategoryID = nil
            }
        } message: {
            Text("Der neue Name wird auf \(renameDraft.isEmpty ? "die Kategorie" : renameDraft) geändert.")
        }
    }
}

private struct CategoryCard: View {
    let category: Category
    let currencyFormatter: (Double) -> String
    let onAddExpense: () -> Void
    let onDelete: () -> Void
    let onRename: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                NavigationLink(destination: ExpenseListView(categoryID: category.id)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)

                        Text(currencyFormatter(category.amount))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }

                Spacer()

                Button(action: onAddExpense) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                }
            }

            if category.expenses.isEmpty {
                Text("Noch keine Ausgaben in dieser Kategorie.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(category.expenses.prefix(3))) { expense in
                        HStack {
                            Text(expense.name)
                            Spacer()
                            Text(currencyFormatter(expense.amount))
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(category.color)
        .cornerRadius(16)
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onLongPressGesture {
            onRename()
        }
    }
}

struct AddExpenseView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    let categoryID: Category.ID

    @State private var item = ""
    @State private var amount = ""

    private var categoryName: String {
        appData.categories.first(where: { $0.id == categoryID })?.name ?? "Kategorie"
    }

    private var canSave: Bool {
        let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
        return !item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Double(normalizedAmount) != nil
    }

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Neue Ausgabe")
                    .font(.largeTitle)
                    .bold()

                Text("Kategorie: \(categoryName)")

                TextField("Was hast du gekauft?", text: $item)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                TextField("Betrag (\(appData.selectedCurrencyCode))", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .keyboardType(.decimalPad)

                Button("Speichern") {
                    let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
                    if let value = Double(normalizedAmount) {
                        appData.addExpense(name: item, amount: value, to: categoryID)
                    }
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
            }
        }
    }
}

struct ExpenseListView: View {
    @EnvironmentObject private var appData: AppData

    let categoryID: Category.ID

    private var category: Category? {
        appData.categories.first(where: { $0.id == categoryID })
    }

    private var expenses: [Expense] {
        category?.expenses ?? []
    }

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()

            VStack {
                Text(category?.name ?? "Kategorie")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(spacing: 12) {
                        if expenses.isEmpty {
                            Text("Noch keine Ausgaben eingetragen.")
                                .foregroundColor(.gray)
                                .padding(.top, 30)
                        } else {
                            ForEach(expenses) { expense in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(expense.name)
                                        Text(appData.comparisonText(for: expense.amount))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Text(appData.formatExpense(expense.amount))
                                        .bold()

                                    Button {
                                        appData.deleteExpense(expenseID: expense.id, from: categoryID)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

struct NewCategoryView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Neue Kategorie")
                    .font(.largeTitle)
                    .bold()

                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Button("Speichern") {
                    appData.addCategory(named: name)
                    dismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

struct ViewPage: View {
    @EnvironmentObject private var appData: AppData

    var total: Double {
        appData.categories.map { $0.amount }.reduce(0, +)
    }

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()

            VStack {
                Text("Ansicht")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 30)

                DonutChart(categories: appData.categories)
                    .frame(width: 220, height: 220)

                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(appData.categories) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Circle()
                                        .fill(category.color)
                                        .frame(width: 14, height: 14)

                                    Text(category.name)
                                        .font(.title3)

                                    Spacer()

                                    Text(appData.formatCurrency(category.amount))
                                        .font(.title3)
                                        .bold()
                                }

                                if category.expenses.isEmpty {
                                    Text("Noch keine Einträge")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(Array(category.expenses.prefix(2))) { expense in
                                        HStack {
                                            Text(expense.name)
                                            Spacer()
                                            Text(appData.formatCurrency(expense.amount))
                                        }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    .padding(.top, 25)
                }

                Spacer()
            }
        }
    }
}

struct DonutChart: View {
    @EnvironmentObject private var appData: AppData

    var categories: [Category]

    var total: Double {
        categories.map { $0.amount }.reduce(0, +)
    }

    var body: some View {
        ZStack {
            if total == 0 {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 40)

                Text(appData.formatCurrency(0))
                    .font(.title3)
                    .bold()
            } else {
                ForEach(0..<categories.count, id: \.self) { index in
                    if categories[index].amount > 0 {
                        Circle()
                            .trim(from: startAngle(for: index), to: endAngle(for: index))
                            .stroke(categories[index].color, style: StrokeStyle(lineWidth: 40))
                            .rotationEffect(.degrees(-90))
                    }
                }

                Text(appData.formatCurrency(total))
                    .font(.title3)
                    .bold()
            }
        }
    }

    func startAngle(for index: Int) -> CGFloat {
        let previous = categories.prefix(index).map { $0.amount }.reduce(0, +)
        return previous / total
    }

    func endAngle(for index: Int) -> CGFloat {
        let current = categories.prefix(index + 1).map { $0.amount }.reduce(0, +)
        return current / total
    }
}

#Preview {
    NavigationStack {
        ContentView()
            .environmentObject(AppData())
    }
}
