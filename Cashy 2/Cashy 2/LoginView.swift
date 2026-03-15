import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var showRegister = false
    
    
    // Braun Farbe für Buttons
    private let brownColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let lightBlueColor = Color.blue.opacity(0.6)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund (LavaLamp Stil)
                Color.green.opacity(0.15).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // MARK: Titel
                    VStack(spacing: 8) {
                        Text("Cashy")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.black)
                        Text("Sparziele erreichen, leicht gemacht")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // MARK: Eingabefelder
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-Mail")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                            
                            TextField("example@email.com", text: $email)
                                .padding(14)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passwort")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            SecureField("••••••••", text: $password)
                                .padding(14)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Passwort vergessen
                    HStack {
                        Spacer()
                        Button(action: { showForgotPassword = true }) {
                            Text("Passwort vergessen?")
                                .font(.caption)
                                .foregroundColor(lightBlueColor)
                                .underline()
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Anmelden Button
                    Button(action: {}) {
                        Text("Anmelden")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brownColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .disabled(email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
                    
                    Spacer()
                    
                    // MARK: Registrieren Link
                    HStack (spacing: 4) {
                        Text("Noch kein Konto?")
                            .foregroundColor(.gray)
                            
                        
                        Button(action: { showRegister = true }) {
                            Text("Jetzt erstellen")
                                .fontWeight(.semibold)
                                .foregroundColor(lightBlueColor)
                                .underline()
                        }
                    }
                    .font(.system(size: 18, weight: .medium))
                    
                    Spacer().frame(height: 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordSheet(isPresented: $showForgotPassword)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(isPresented: $showRegister)
            }
        }
    }
}

// MARK: - Passwort vergessen Sheet
struct ForgotPasswordSheet: View {
    @Binding var isPresented: Bool
    @State private var forgotEmail = ""
    @State private var showCodeInput = false
    @State private var verificationCode = ""
    @State private var showPasswordReset = false
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmNewPassword = false
    
    private let brownColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    
    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmNewPassword
    }
    
    var passwordsDontMatch: Bool {
        !confirmNewPassword.isEmpty && newPassword != confirmNewPassword
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Passwort zurücksetzen")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Color.clear.frame(width: 30)
            }
            .padding()
            
            if !showCodeInput {
                VStack(spacing: 20) {
                    Text("Gib deine E-Mail-Adresse ein, um einen Bestätigungscode zu erhalten.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("E-Mail")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        
                        TextField("", text: $forgotEmail)
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showCodeInput = true
                    }) {
                        Text("Code senden")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brownColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .disabled(forgotEmail.isEmpty)
                    .opacity(forgotEmail.isEmpty ? 0.5 : 1.0)
                    
                    Spacer()
                }
            } else if !showPasswordReset {
                VStack(spacing: 20) {
                    Text("Bestätigungscode wurde an \(forgotEmail) gesendet.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bestätigungscode")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        
                        TextField("123456", text: $verificationCode)
                            .padding(14)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        showPasswordReset = true
                    }) {
                        Text("Passwort zurücksetzen")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brownColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .disabled(verificationCode.isEmpty)
                    .opacity(verificationCode.isEmpty ? 0.5 : 1.0)
                    
                    
                    Spacer()
                }
            }
            else {
                VStack(spacing: 20) {
                    Text("Neues Passwort festlegen")
                        .font(.headline)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neues Passwort")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        HStack {
                            if showNewPassword {
                                TextField("Neues Passwort", text: $newPassword)
                            } else {
                                SecureField("Neues Passwort", text: $newPassword)
                            }
                            Button(action: { showNewPassword.toggle() }) {
                                Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neues Passwort bestätigen")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .fontWeight(.semibold)
                        HStack {
                            if showConfirmNewPassword {
                                TextField("Passwort bestätigen", text: $confirmNewPassword)
                            } else {
                                SecureField("Passwort bestätigen", text: $confirmNewPassword)
                            }
                            Button(action: { showConfirmNewPassword.toggle() }) {
                                Image(systemName: showConfirmNewPassword ? "eye.slash" : "eye")
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

                    Button(action: {
                        // Speichern-Logik für neues Passwort hier einfügen
                        isPresented = false
                    }) {
                        Text("Neues Passwort speichern")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(brownColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal)
                    .disabled(!passwordsMatch)
                    .opacity(passwordsMatch ? 1.0 : 0.5)

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.15))
    }
}

#Preview {
    LoginView()
}
