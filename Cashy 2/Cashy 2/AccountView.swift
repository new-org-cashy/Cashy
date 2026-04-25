import SwiftUI // Importiert SwiftUI für UI-Elemente
import PhotosUI // Importiert PhotosUI, damit man Fotos aus der Galerie auswählen kann
import UIKit

// Die Kontoansicht verwaltet einfache Profilinformationen lokal in UserDefaults,
// inklusive optionalem Profilbild aus der Fotogalerie.
// MARK: - AccountView
struct AccountView: View { // Haupt-View für das Benutzerkonto
    
    // MARK: - Keys für UserDefaults
    private let nameKey = "user_name" // Schlüssel für Name speichern
    private let emailKey = "user_email" // Schlüssel für E-Mail speichern
    private let passwordKey = "user_password" // Schlüssel für Passwort speichern
    private let imageKey = "user_profile_image" // Schlüssel für Profilbild speichern
    
    // MARK: - States für Benutzerdaten
    @State private var name: String = "" // Name des Benutzers
    @State private var email: String = "" // E-Mail des Benutzers
    @State private var password: String = "" // Passwort des Benutzers
    
    @State private var selectedItem: PhotosPickerItem? // Ausgewähltes Foto
    @State private var profileUIImage: UIImage? // Profilbild als UIImage
    
    @State private var showSavedAlert = false // Anzeige für "gespeichert" Alert
    
    var body: some View {
        
        ZStack { // Hintergrund + Inhalt
            Color.green.opacity(0.25) // Halbtransparenter grüner Hintergrund
                .ignoresSafeArea() // Füllt den ganzen Bildschirm
            
            ScrollView { // Scrollbarer Bereich für Inhalt
                VStack(spacing: 25) { // Vertikale Anordnung
                    
                    // MARK: Profilbild
                    PhotosPicker(selection: $selectedItem, matching: .images) { // Button um Foto auszuwählen
                        
                        if let uiImage = profileUIImage { // Wenn ein Bild vorhanden
                            Image(uiImage: uiImage) // Zeige das ausgewählte Bild
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle()) // Rundes Bild
                        } else {
                            Image(systemName: "person.circle.fill") // Standard Icon
                                .resizable()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.green)
                        }
                    }
                    .onChange(of: selectedItem) { // Wenn neues Bild gewählt wird
                        loadImage() // Lade das Bild
                    }
                    .padding(.top, 20) // Abstand oben
                    
                    // MARK: Benutzerfelder
                    VStack(spacing: 16) {
                        // Die Profilfelder und das Speichern sind bewusst simpel gehalten,
                        // weil diese Ansicht aktuell nur lokale Gerätedaten pflegt.
                        customField(title: "Name", text: $name) // Eingabefeld Name
                        customField(title: "E-Mail", text: $email) // Eingabefeld E-Mail
                        
                        VStack(alignment: .leading) { // Passwortfeld
                            Text("Passwort")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField("Passwort", text: $password) // Sichere Eingabe
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .foregroundColor(.black)
                        }
                        
                        // Button zum Speichern
                        Button {
                            saveUserData() // Daten speichern
                            showSavedAlert = true // Alert anzeigen
                        } label: {
                            Text("Änderungen speichern")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.black)
                                .cornerRadius(16)
                        }
                        .padding(.top, 10) // Abstand oben
                    }
                    .padding(16)
                    .background(Color.green.opacity(0.18)) // Hintergrundfarbe
                    .cornerRadius(22)
                    .padding(.horizontal) // Außenabstand
                }
                .padding(.bottom, 40) // Abstand unten
            }
        }
        .navigationBarTitleDisplayMode(.inline) // Titel inline anzeigen
        .toolbar { // Toolbar für Navigation
            ToolbarItem(placement: .principal) {
                Text("Konto") // Titel in der Mitte
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .preferredColorScheme(.light) // Hellmodus erzwingen
        .onAppear {
            loadUserData() // Beim Laden Daten aus UserDefaults holen
        }
        .alert("Gespeichert ✅", isPresented: $showSavedAlert) { // Alert anzeigen
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - Benutzerdefiniertes Textfeld
    private func customField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title) // Titel des Feldes
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField(title, text: text) // Eingabefeld
                .padding()
                .background(Color.white.opacity(0.7))
                .cornerRadius(12)
                .foregroundColor(.black)
        }
    }
    
    // MARK: - Speichern der Benutzerdaten
    private func saveUserData() {
        // Name, Mail, Passwort und Bild werden getrennt gespeichert,
        // damit die Ansicht beim nächsten Öffnen den letzten Stand wiederherstellen kann.
        UserDefaults.standard.set(name, forKey: nameKey) // Name speichern
        UserDefaults.standard.set(email, forKey: emailKey) // E-Mail speichern
        UserDefaults.standard.set(password, forKey: passwordKey) // Passwort speichern
        
        if let image = profileUIImage, // Profilbild speichern, falls vorhanden
           let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: imageKey)
        }
    }
    
    // MARK: - Laden der Benutzerdaten
    private func loadUserData() {
        // Beim Öffnen werden alle bekannten Profilwerte geladen
        // und optional wieder in ein UIImage für die Vorschau umgewandelt.
        name = UserDefaults.standard.string(forKey: nameKey) ?? "" // Name laden
        email = UserDefaults.standard.string(forKey: emailKey) ?? "" // E-Mail laden
        password = UserDefaults.standard.string(forKey: passwordKey) ?? "" // Passwort laden
        
        if let imageData = UserDefaults.standard.data(forKey: imageKey), // Profilbild laden
           let uiImage = UIImage(data: imageData) {
            profileUIImage = uiImage
        }
    }
    
    // MARK: - Bild aus PhotosPicker laden
    private func loadImage() {
        guard let selectedItem = selectedItem else { return } // Prüfen, ob Bild ausgewählt
        
        // Das ausgewählte Foto wird asynchron geladen und danach im State gehalten,
        // damit die UI sofort aktualisiert und später gespeichert werden kann.
        selectedItem.loadTransferable(type: Data.self) { result in // Daten aus Picker laden
            DispatchQueue.main.async { // UI auf Hauptthread aktualisieren
                switch result {
                case .success(let data):
                    if let data = data,
                       let uiImage = UIImage(data: data) { // UIImage erstellen
                        profileUIImage = uiImage
                    }
                case .failure:
                    print("Bild konnte nicht geladen werden") // Fehler
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AccountView() // Vorschau für AccountView
    }
}
