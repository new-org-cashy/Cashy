import SwiftUI

// MARK: EXPENSE MODEL

struct Expense: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
}

// MARK: CATEGORY MODEL

struct Category: Identifiable {
    let id = UUID()
    var name: String
    var color: Color
    var expenses: [Expense] = []
    
    var amount: Double {
        expenses.map{$0.amount}.reduce(0,+)
    }
}

// MARK: MAIN VIEW

struct ContentView: View {
    
    @State private var categories: [Category] = [
        Category(name: "Skincare", color: Color(red: 0.55, green: 0.70, blue: 0.55)),
        Category(name: "Make-Up", color: Color(red: 0.45, green: 0.65, blue: 0.50)),
        Category(name: "Drogen", color: Color(red: 0.40, green: 0.60, blue: 0.45)),
        Category(name: "Snacks", color: Color(red: 0.35, green: 0.50, blue: 0.30)),
        Category(name: "Abos", color: Color(red: 0.55, green: 0.50, blue: 0.35)),
        Category(name: "Kleidung", color: Color(red: 0.50, green: 0.45, blue: 0.30))
    ]
    
    @State private var selectedIndex = 0
    @State private var showAddExpense = false
    @State private var showNewCategory = false
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color(red: 0.85, green: 0.93, blue: 0.82)
                    .ignoresSafeArea()
                
                VStack {
                    
                    HStack {
                        
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Ausgaben")
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        NavigationLink(destination: ViewPage(categories: $categories)) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                Text("Ansicht")
                            }
                            .padding(8)
                            .background(Color.orange.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding()
                    
                    ScrollView {
                        
                        VStack(spacing: 14) {
                            
                            ForEach(categories.indices, id:\.self) { i in
                                
                                HStack {
                                    
                                    NavigationLink(
                                        destination: ExpenseListView(category: $categories[i])
                                    ) {
                                        Text(categories[i].name)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        selectedIndex = i
                                        showAddExpense = true
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button {
                                        categories.remove(at: i)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(categories[i].color)
                                .cornerRadius(16)
                                .padding(.horizontal)
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
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(categories: $categories, index: selectedIndex)
        }
        .sheet(isPresented: $showNewCategory) {
            NewCategoryView(categories: $categories)
        }
    }
}

// MARK: ADD EXPENSE

struct AddExpenseView: View {
    
    @Binding var categories: [Category]
    var index: Int
    
    @State private var item = ""
    @State private var amount = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        ZStack {
            
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("Neue Ausgabe")
                    .font(.largeTitle)
                    .bold()
                
                Text("Kategorie: \(categories[index].name)")
                
                TextField("Was hast du gekauft?", text: $item)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                TextField("Betrag €", text: $amount)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .keyboardType(.decimalPad)
                
                Button("Speichern") {
                    
                    if let value = Double(amount) {
                        let newExpense = Expense(name: item, amount: value)
                        categories[index].expenses.append(newExpense)
                    }
                    
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
}

// MARK: EXPENSE LIST

struct ExpenseListView: View {
    
    @Binding var category: Category
    
    var body: some View {
        
        ZStack {
            
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()
            
            VStack {
                
                Text(category.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom,20)
                
                ScrollView {
                    
                    VStack(spacing:12) {
                        
                        ForEach(category.expenses) { expense in
                            
                            HStack {
                                
                                Text(expense.name)
                                
                                Spacer()
                                
                                Text("\(Int(expense.amount))€")
                                    .bold()
                                
                                Button {
                                    if let index = category.expenses.firstIndex(where: {$0.id == expense.id}) {
                                        category.expenses.remove(at: index)
                                    }
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
                
                Spacer()
            }
        }
    }
}

// MARK: NEW CATEGORY

struct NewCategoryView: View {
    
    @Binding var categories: [Category]
    
    @State private var name = ""
    
    @Environment(\.dismiss) var dismiss
    
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
                    
                    let newCategory = Category(
                        name: name,
                        color: .gray
                    )
                    
                    categories.append(newCategory)
                    
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

// MARK: VIEW PAGE

struct ViewPage: View {
    
    @Binding var categories: [Category]
    
    var total: Double {
        categories.map{$0.amount}.reduce(0,+)
    }
    
    var body: some View {
        
        ZStack {
            
            Color(red: 0.85, green: 0.93, blue: 0.82)
                .ignoresSafeArea()
            
            VStack {
                
                Text("Ansicht")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom,30)
                
                DonutChart(categories: categories)
                    .frame(width:220,height:220)
                
                ScrollView {
                    
                    VStack(spacing:14) {
                        
                        ForEach(categories.indices, id:\.self) { i in
                            
                            HStack {
                                
                                Circle()
                                    .fill(categories[i].color)
                                    .frame(width:14,height:14)
                                
                                Text(categories[i].name)
                                    .font(.title3)
                                
                                Spacer()
                                
                                Text("\(Int(categories[i].amount))€")
                                    .font(.title2)
                                    .bold()
                            }
                            .padding(.horizontal)
                            .padding(.vertical,8)
                        }
                    }
                    .padding(.top,25)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: DONUT CHART

struct DonutChart: View {
    
    var categories: [Category]
    
    var total: Double {
        categories.map{$0.amount}.reduce(0,+)
    }
    
    var body: some View {
        
        ZStack {
            
            if total == 0 {
                
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 40)
                
                Text("0€")
                    .font(.title)
                    .bold()
                
            } else {
                
                ForEach(0..<categories.count, id:\.self) { i in
                    
                    if categories[i].amount > 0 {
                        
                        Circle()
                            .trim(
                                from: startAngle(for: i),
                                to: endAngle(for: i)
                            )
                            .stroke(
                                categories[i].color,
                                style: StrokeStyle(lineWidth: 40)
                            )
                            .rotationEffect(.degrees(-90))
                    }
                }
                
                Text("\(Int(total))€")
                    .font(.title)
                    .bold()
            }
        }
    }
    
    func startAngle(for index: Int) -> CGFloat {
        let previous = categories.prefix(index).map{$0.amount}.reduce(0,+)
        return previous / total
    }
    
    func endAngle(for index: Int) -> CGFloat {
        let current = categories.prefix(index+1).map{$0.amount}.reduce(0,+)
        return current / total
    }
}

