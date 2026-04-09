import SwiftUI
private let brownColor = Color(red: 0.6, green: 0.4, blue: 0.2)
struct RegisterView: View {
    
    @Binding var isPresented: Bool
    @EnvironmentObject private var appData: AppData
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showForgotPassword = false
    @State private var showLogin = false
    @State private var showRegisterError = false
    @State private var registerErrorMessage = ""
    
    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }
    
    var passwordsDontMatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }
    
    var isFormValid: Bool {
        !email.isEmpty && passwordsMatch && password.count >= 6
    }
    
    var body: some View {
        ZStack {
            // Hintergrund
            Color.green.opacity(0.15).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // MARK: Header
                HStack {
                    Spacer()
                    Text("Konto erstellen")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 60)
                    Spacer()
                }
                .padding()
                .padding()
                
                Spacer(minLength: 40)
                
                ScrollView {
                    VStack(spacing: 16) {
                        Spacer(minLength: 20)
                        
                        // MARK: E-Mail Feld
                    
                        VStack(alignment: .leading, spacing: 8) {

                            Text("E-Mail")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            TextField("", text: $email)
                                .padding(14)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal)
                        
                        // MARK: Passwort Feld
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            HStack {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textContentType(.oneTimeCode)
                                } else {
                                    SecureField("", text: $password)
                                        .textContentType(.oneTimeCode)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("Mindestens 6 Zeichen erforderlich")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: Passwort bestätigen Feld
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort bestätigen")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("", text: $confirmPassword)
                                        .textContentType(.oneTimeCode)
                                } else {
                                    SecureField("", text: $confirmPassword)
                                        .textContentType(.oneTimeCode)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            
                            if passwordsDontMatch {
                                Text("Passwörter stimmen nicht überein")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                        
                        // MARK: Konto erstellen Button
                        Button {
                            let didRegister = appData.registerAccount(email: email, password: password)

                            guard didRegister else {
                                registerErrorMessage = "Für diese E-Mail gibt es bereits ein Konto oder die Eingabe ist unvollständig."
                                showRegisterError = true
                                return
                            }

                            isPresented = false
                        } label: {
                            Text("Konto erstellen")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(brownColor)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal)
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                    .padding(.top, 0)
                }
                
                Spacer(minLength: 80)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Registrierung fehlgeschlagen", isPresented: $showRegisterError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(registerErrorMessage)
        }
    }

}

#Preview {
    NavigationStack {
        RegisterView(isPresented: .constant(true))
            .environmentObject(AppData())
    }
}
