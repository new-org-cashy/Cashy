import SwiftUI

extension Color {
    static let backgroundGreen = Color(red: 147/255, green: 193/255, blue: 151/255)
    static let lightGreen = Color(red: 215/255, green: 223/255, blue: 201/255)
}

struct Currency: Identifiable {
    let id = UUID()
    let name: String
    let code: String
}

struct Fragen: View {
    @EnvironmentObject private var appData: AppData

    @State private var searchText = ""
    @State private var isRecording = false
    @State private var selectedCurrency: Currency?
    @State private var goToNextPage = false

    let currencies: [Currency] = [
        Currency(name: "Albanischer Lek", code: "ALL"),
        Currency(name: "Algerischer Dinar", code: "DZD"),
        Currency(name: "Argentinischer Peso", code: "ARS"),
        Currency(name: "Armenischer Dram", code: "AMD"),
        Currency(name: "Australischer Dollar", code: "AUD"),
        Currency(name: "Aserbaidschan-Manat", code: "AZN"),
        Currency(name: "Ägyptisches Pfund", code: "EGP"),
        Currency(name: "Bangladesch-Taka", code: "BDT"),
        Currency(name: "Belarussischer Rubel", code: "BYN"),
        Currency(name: "Bhutanese Ngultrum", code: "BTN"),
        Currency(name: "Bosnisch-Konvertible Mark", code: "BAM"),
        Currency(name: "Brasilianischer Real", code: "BRL"),
        Currency(name: "Brunei-Dollar", code: "BND"),
        Currency(name: "Bulgarischer Lew", code: "BGN"),
        Currency(name: "Chilenischer Peso", code: "CLP"),
        Currency(name: "Chinesischer Yuan", code: "CNY"),
        Currency(name: "Dänische Krone", code: "DKK"),
        Currency(name: "Euro", code: "EUR"),
        Currency(name: "Fidschi-Dollar", code: "FJD"),
        Currency(name: "Färöer-Krone", code: "FOK"),
        Currency(name: "Georgischer Lari", code: "GEL"),
        Currency(name: "Ghanaischer Cedi", code: "GHS"),
        Currency(name: "Britisches Pfund", code: "GBP"),
        Currency(name: "Hongkong-Dollar", code: "HKD"),
        Currency(name: "Ungarischer Forint", code: "HUF"),
        Currency(name: "Island-Krone", code: "ISK"),
        Currency(name: "Indische Rupie", code: "INR"),
        Currency(name: "Indonesische Rupiah", code: "IDR"),
        Currency(name: "Jordanischer Dinar", code: "JOD"),
        Currency(name: "Japanischer Yen", code: "JPY"),
        Currency(name: "Kambodschanischer Riel", code: "KHR"),
        Currency(name: "Kanadischer Dollar", code: "CAD"),
        Currency(name: "Kasachischer Tenge", code: "KZT"),
        Currency(name: "Kenia-Schilling", code: "KES"),
        Currency(name: "Kirgisischer Som", code: "KGS"),
        Currency(name: "Kroatische Kuna", code: "HRK"),
        Currency(name: "Kuwait-Dinar", code: "KWD"),
        Currency(name: "Laotischer Kip", code: "LAK"),
        Currency(name: "Libanesisches Pfund", code: "LBP"),
        Currency(name: "Madagassischer Ariary", code: "MGA"),
        Currency(name: "Malawi-Kwacha", code: "MWK"),
        Currency(name: "Malaysischer Ringgit", code: "MYR"),
        Currency(name: "Mauritius-Rupie", code: "MUR"),
        Currency(name: "Mexikanischer Peso", code: "MXN"),
        Currency(name: "Myanmarischer Kyat", code: "MMK"),
        Currency(name: "Neuer Taiwan-Dollar", code: "TWD"),
        Currency(name: "Neuseeland-Dollar", code: "NZD"),
        Currency(name: "Nigerianischer Naira", code: "NGN"),
        Currency(name: "Norwegische Krone", code: "NOK"),
        Currency(name: "Nepalesische Rupie", code: "NPR"),
        Currency(name: "Pakistanische Rupie", code: "PKR"),
        Currency(name: "Papua-Neuguinea-Kina", code: "PGK"),
        Currency(name: "Peruanischer Sol", code: "PEN"),
        Currency(name: "Polnischer Złoty", code: "PLN"),
        Currency(name: "Rumänischer Leu", code: "RON"),
        Currency(name: "Russischer Rubel", code: "RUB"),
        Currency(name: "Samoa-Tālā", code: "WST"),
        Currency(name: "Saudi-Riyal", code: "SAR"),
        Currency(name: "Schweizer Franken", code: "CHF"),
        Currency(name: "Schwedische Krone", code: "SEK"),
        Currency(name: "Singapur-Dollar", code: "SGD"),
        Currency(name: "Simbabwer Dollar", code: "ZWL"),
        Currency(name: "Südafrikanischer Rand", code: "ZAR"),
        Currency(name: "Sri-Lanka-Rupie", code: "LKR"),
        Currency(name: "Tadschikischer Somoni", code: "TJS"),
        Currency(name: "Tschechische Krone", code: "CZK"),
        Currency(name: "Thailändischer Baht", code: "THB"),
        Currency(name: "Tunesischer Dinar", code: "TND"),
        Currency(name: "Tonga-Paʻanga", code: "TOP"),
        Currency(name: "Türkische Lira", code: "TRY"),
        Currency(name: "Turkmenistan-Manat", code: "TMT"),
        Currency(name: "Ukrainische Hrywnja", code: "UAH"),
        Currency(name: "Uganda-Schilling", code: "UGX"),
        Currency(name: "Usbekistan-Sum", code: "UZS"),
        Currency(name: "US-Dollar", code: "USD"),
        Currency(name: "VAE-Dirham", code: "AED"),
        Currency(name: "Venezolanischer Bolívar", code: "VES"),
        Currency(name: "Zambischer Kwacha", code: "ZMW")
    ]

    var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return currencies
        }

        return currencies.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.code.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Wähle deine Währung")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Image(systemName: "magnifyingglass")

                TextField("Search", text: $searchText)
                    .textInputAutocapitalization(.never)

                Button {
                    isRecording.toggle()
                } label: {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filteredCurrencies) { currency in
                        HStack {
                            Text(currency.name)
                            Spacer()
                            Text(currency.code)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(selectedCurrency?.id == currency.id ? Color.lightGreen : Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedCurrency = currency
                        }
                    }
                }
            }

            Button {
                guard let selectedCurrency = selectedCurrency else { return }
                appData.updateCurrency(name: selectedCurrency.name, code: selectedCurrency.code)
                goToNextPage = true
            } label: {
                Text("Weiter")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color.black)
            .cornerRadius(10)
            .disabled(selectedCurrency == nil)
            .opacity(selectedCurrency == nil ? 0.5 : 1)
        }
        .padding()
        .padding(.top, 60)
        .background(Color.backgroundGreen)
        .ignoresSafeArea()
        .navigationDestination(isPresented: $goToNextPage) {
            BadHabitView()
        }
    }
}

struct BadHabitView: View {
    @EnvironmentObject private var appData: AppData

    @State private var badHabitText = ""
    @State private var goToSavingsGoal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Was sind deine schlechten\nAngewohnheiten im Umgang\nmit Geld?")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Deine Antwort...", text: $badHabitText)
                .padding()
                .background(Color.lightGreen)
                .cornerRadius(12)

            HStack(spacing: 20) {
                Button {
                    badHabitText = "Keine Ahnung"
                    appData.saveBadHabit(badHabitText)
                    goToSavingsGoal = true
                } label: {
                    Text("Keine Ahnung")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.lightGreen)
                        .cornerRadius(12)
                }

                Button {
                    appData.saveBadHabit(badHabitText)
                    goToSavingsGoal = true
                } label: {
                    Text("Weiter")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }

            Spacer()
        }
        .padding()
        .padding(.top, 20)
        .background(Color.backgroundGreen)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationDestination(isPresented: $goToSavingsGoal) {
            SparZielView()
        }
    }
}

struct SparZielView: View {
    @EnvironmentObject private var appData: AppData

    @State private var savingsGoal = ""
    @State private var goToIncome = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Was ist dein Sparziel?")
                .font(.title2)
                .fontWeight(.bold)

            TextField("Betrag eingeben...", text: $savingsGoal)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.lightGreen)
                .cornerRadius(12)

            Button {
                let normalizedGoal = savingsGoal.replacingOccurrences(of: ",", with: ".")
                if let goalValue = Double(normalizedGoal), goalValue > 0 {
                    appData.updateSavingsGoal(goalValue)
                }
                appData.completeOnboarding()
                goToIncome = true
            } label: {
                Text("Weiter")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .padding(.top, 20)
        .background(Color.backgroundGreen)
        .ignoresSafeArea(.container, edges: .bottom)
        .navigationDestination(isPresented: $goToIncome) {
            HomeView()
        }
    }
}

#Preview {
    NavigationStack {
        Fragen()
            .environmentObject(AppData())
    }
}
