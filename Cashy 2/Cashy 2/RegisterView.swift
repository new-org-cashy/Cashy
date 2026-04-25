import SwiftUI
// Gemeinsame Akzentfarbe für den primären Call-to-Action der Registrierung.
private let brownColor = Color(red: 0.6, green: 0.4, blue: 0.2)

// Die Registrierung validiert Eingaben lokal und legt nach Erfolg direkt einen neuen Account im AppData-Store an.
struct RegisterView: View {
    // Das Binding erlaubt der Elternansicht, die Registrierung wieder zu schließen.
    @Binding var isPresented: Bool
    // AppData übernimmt die eigentliche Account-Erstellung und Persistenz.
    @EnvironmentObject private var appData: AppData

    // Eingabe für die E-Mail-Adresse des neuen Accounts.
    @State private var email = ""
    // Eingabe für das gewünschte Passwort.
    @State private var password = ""
    // Zweite Eingabe zur Bestätigung des Passworts.
    @State private var confirmPassword = ""
    // Steuert, ob das erste Passwort offen oder verdeckt angezeigt wird.
    @State private var showPassword = false
    // Steuert, ob das Bestätigungs-Passwort offen oder verdeckt angezeigt wird.
    @State private var showConfirmPassword = false
    // Aktuell ungenutzter State für mögliche spätere Forgot-Password-Verknüpfung.
    @State private var showForgotPassword = false
    // Aktuell ungenutzter State für einen möglichen Rücksprung zum Login-Flow.
    @State private var showLogin = false
    // Öffnet den Fehlerdialog bei fehlgeschlagener Registrierung.
    @State private var showRegisterError = false
    // Enthält die konkrete Fehlermeldung für den Alert.
    @State private var registerErrorMessage = ""

    // Das Formular gilt nur dann als passend, wenn beide Passwörter vorhanden und identisch sind.
    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    // Dieser Wert steuert die sichtbare Fehlermeldung unter dem Bestätigungsfeld.
    var passwordsDontMatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    // Der Button wird erst aktiviert, wenn E-Mail vorhanden ist, Passwörter übereinstimmen
    // und das Passwort die Mindestlänge erreicht.
    var isFormValid: Bool {
        !email.isEmpty && passwordsMatch && password.count >= 6
    }

    var body: some View {
        // ZStack legt zuerst den Hintergrund und dann den eigentlichen Formularinhalt darüber.
        ZStack {
            // Hintergrund
            Color.green.opacity(0.15).ignoresSafeArea()
            
            // Die Hauptstruktur besteht aus Header, scrollbarem Formular und unterem Freiraum.
            VStack(spacing: 20) {
                // MARK: Header
                HStack {
                    // Das X schließt die Registrierungsansicht ohne weitere Aktion.
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                    }

                    // Spacer schiebt den Titel in die Mitte.
                    Spacer()

                    // Der Titel macht klar, dass hier ein neuer Account angelegt wird.
                    Text("Konto erstellen")
                        .font(.title)
                        .fontWeight(.bold)

                    // Der zweite Spacer balanciert die rechte Seite optisch aus.
                    Spacer()

                    // Unsichtbarer Platzhalter hält den Titel mittig, obwohl links ein Button sitzt.
                    Color.clear.frame(width: 20, height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                // Abstand zwischen Header und Formular.
                Spacer(minLength: 40)
                
                ScrollView {
                    // Das ScrollView sorgt dafür, dass das Formular auch bei kleinerem Display oder Tastatur erreichbar bleibt.
                    VStack(spacing: 16) {
                        Spacer(minLength: 20)
                        
                        // Die Felder prüfen Eingabequalität direkt im UI,
                        // damit die Registrierung erst mit konsistenten Daten möglich ist.
                        // MARK: E-Mail Feld
                    
                        VStack(alignment: .leading, spacing: 8) {
                            // Feldlabel für die E-Mail-Eingabe.
                            Text("E-Mail")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            // Das TextField bindet direkt an den E-Mail-State.
                            TextField("", text: $email)
                                // Innenabstand macht das Feld leichter bedienbar.
                                .padding(14)
                                // Halbtransparenter Hintergrund trennt das Feld vom Screen-Hintergrund.
                                .background(Color.white.opacity(0.7))
                                // Abgerundete Ecken passend zum restlichen Formularstil.
                                .cornerRadius(12)
                                // E-Mail-Tastatur erleichtert passende Eingaben.
                                .keyboardType(.emailAddress)
                                // Autokorrektur soll E-Mail-Adressen nicht verändern.
                                .autocorrectionDisabled()
                                // Großschreibung wird deaktiviert, damit E-Mail-Adressen konsistent bleiben.
                                .textInputAutocapitalization(.never)
                        }
                        // Horizontaler Abstand hält das Feld vom Rand weg.
                        .padding(.horizontal)
                        
                        // MARK: Passwort Feld
                        VStack(alignment: .leading, spacing: 8) {
                            // Feldlabel für das Passwort.
                            Text("Passwort")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            // HStack kombiniert Eingabefeld und Eye-Button in einer Zeile.
                            HStack {
                                // Wenn showPassword aktiv ist, wird das Passwort offen als Text gezeigt.
                                if showPassword {
                                    TextField("", text: $password)
                                        // OneTimeCode verhindert störende Passwort-Autofill-Effekte im Klartextfeld.
                                        .textContentType(.oneTimeCode)
                                } else {
                                    // Standardmäßig bleibt das Passwort verdeckt.
                                    SecureField("", text: $password)
                                        .textContentType(.oneTimeCode)
                                }
                                
                                // Mit dem Button kann der Nutzer die Passwortsichtbarkeit umschalten.
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            // Gemeinsames Styling für Feld und Button-Zeile.
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            
                            // Die Mindestlänge wird direkt unter dem Feld erklärt, sobald ein zu kurzes Passwort vorliegt.
                            if !password.isEmpty && password.count < 6 {
                                Text("Mindestens 6 Zeichen erforderlich")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: Passwort bestätigen Feld
                        VStack(alignment: .leading, spacing: 8) {
                            // Feldlabel für die Passwort-Bestätigung.
                            Text("Passwort bestätigen")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            // Dieselbe Struktur wie oben, diesmal für die Wiederholung des Passworts.
                            HStack {
                                // Optional sichtbare Eingabe für die Bestätigung.
                                if showConfirmPassword {
                                    TextField("", text: $confirmPassword)
                                        .textContentType(.oneTimeCode)
                                } else {
                                    // Standardmäßig bleibt auch dieses Passwort verdeckt.
                                    SecureField("", text: $confirmPassword)
                                        .textContentType(.oneTimeCode)
                                }
                                
                                // Eye-Button für die zweite Eingabe.
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            
                            // Wenn die beiden Passwörter abweichen, wird sofort ein Hinweis eingeblendet.
                            if passwordsDontMatch {
                                Text("Passwörter stimmen nicht überein")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Abstand vor dem primären Button.
                        Spacer(minLength: 20)
                        
                        // MARK: Konto erstellen Button
                        Button {
                            // Die eigentliche Registrierung läuft zentral über AppData.
                            let didRegister = appData.registerAccount(email: email, password: password)

                            // Die eigentliche Account-Erstellung liegt im zentralen Datenmodell,
                            // damit Registrierung und späterer Login dieselbe Quelle benutzen.
                            guard didRegister else {
                                // Im Fehlerfall wird die Meldung vorbereitet und per Alert angezeigt.
                                registerErrorMessage = "Für diese E-Mail gibt es bereits ein Konto oder die Eingabe ist unvollständig."
                                showRegisterError = true
                                return
                            }

                            // Bei Erfolg wird die Ansicht geschlossen und der Nutzer kehrt zum vorherigen Flow zurück.
                            isPresented = false
                        } label: {
                            // Sichtbarer Primär-CTA für die Registrierung.
                            Text("Konto erstellen")
                                // Der Button nutzt die komplette verfügbare Breite.
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(brownColor)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        // Solange das Formular ungültig ist, kann kein Account erstellt werden.
                        .disabled(!isFormValid)
                        // Zusätzlich wird der deaktivierte Zustand optisch abgeblendet.
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    .padding(.top, 0)
                }
                
                // Unterer Abstand hält den Inhalt optisch vom Safe Area Rand weg.
                Spacer(minLength: 80)
            }
        }
        // Der Standard-Back-Button wird ausgeblendet, weil hier schon ein eigenes Schließen-X existiert.
        .navigationBarBackButtonHidden(true)
        // Der Alert zeigt verständlich an, warum die Registrierung nicht geklappt hat.
        .alert("Registrierung fehlgeschlagen", isPresented: $showRegisterError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(registerErrorMessage)
        }
    }

}

#Preview {
    // Vorschau mit konstant geöffnetem Screen und eingebundenem AppData-Objekt.
    NavigationStack {
        RegisterView(isPresented: .constant(true))
            .environmentObject(AppData())
    }
}
