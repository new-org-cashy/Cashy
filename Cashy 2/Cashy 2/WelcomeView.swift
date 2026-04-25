import SwiftUI

struct WelcomeView: View {

    @State private var animateCircle = false
    @State private var showLogin = false

    var body: some View {
        ZStack {
            if showLogin {
                LoginView()
                    .transition(.opacity)
            } else {
                content
            }
        }
    }

    var content: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            // MARK: - IMAGE (weiter unten)
                       Image("mask") // 👈 Asset Name hier einsetzen
                           .resizable()
                           .scaledToFit()
                           .frame(width: 250)
                           .opacity(0.9)
                           .offset(y: 120) // 👈 weiter nach unten (hier kannst du spielen)


            // MARK: - Kreis
            Circle()
                .fill(Color.green.opacity(0.25))
                .frame(
                    width: animateCircle ? 1200 : 360,
                    height: animateCircle ? 1200 : 360
                )
                .offset(
                    x: animateCircle ? 0 : 10,
                    y: animateCircle ? 0 : -200
                )
                .animation(.easeInOut(duration: 0.6), value: animateCircle)

            VStack {
                Spacer().frame(height: 80)

                VStack(spacing: 10) {
                    Text("Cashy")
                        .font(.system(size: 52, weight: .bold))

                    Text("Mit Cashy kannst du es dir leisten!")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                Button(action: {
                    animateCircle = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showLogin = true
                        }
                    }
                }) {
                    Text("Los geht's")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.green,
                                    Color.green.opacity(0.8),
                                    Color.green.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .padding(.horizontal, 32)
                }

                Spacer().frame(height: 50)
            }
        }
    }
}

// MARK: - LoginView

struct loginView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Text("Login Screen")
                .font(.largeTitle)
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
