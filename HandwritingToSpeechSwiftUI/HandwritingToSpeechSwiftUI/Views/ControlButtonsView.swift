import SwiftUI

// Enhanced speak button component
@MainActor
struct SpeakControlButton: View {
    var text: String
    var isLoading: Bool
    var onSpeak: () -> Void
    
    // Create separate components for the button
    private var buttonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.3), lineWidth: 2)
    }
    
    var body: some View {
        Button(action: onSpeak) {
            VStack(spacing: 8) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 36))
                    .symbolEffect(.pulse, options: .repeating, value: isLoading)
                
                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                            .scaleEffect(1.2)
                            .padding(.trailing, 4)
                    }
                    Text("Lire à haute voix")
                        .font(.title)
                        .bold()
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(buttonBackground)
            .overlay(buttonBorder)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: 0.95,
            pressedColor: Color.blue.opacity(0.7),
            normalColor: .clear
        ))
        .disabled(isLoading || text.isEmpty)
        .accessibilityLabel("Lire à haute voix")
        .accessibilityHint("Lit le texte reconnu à haute voix")
    }
}

// Enhanced repeat button
@MainActor
struct RepeatControlButton: View {
    var lastText: String
    var isLoading: Bool
    var onRepeat: () -> Void
    
    // Text preview with truncation
    private var textPreview: String {
        guard !lastText.isEmpty else { return "" }
        
        return lastText.count > 20 ? 
            "\"\(lastText.prefix(20))...\"" : 
            "\"\(lastText)\""
    }
    
    var body: some View {
        Button(action: onRepeat) {
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                    Text("Répéter")
                        .font(.title2)
                        .bold()
                    if isLoading {
                        ProgressView().tint(.white)
                    }
                }
                
                // Show preview of the text to repeat
                if !lastText.isEmpty {
                    Text(textPreview)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .disabled(isLoading || lastText.isEmpty)
        .accessibilityLabel("Répéter le dernier texte")
        .accessibilityHint("Lit à nouveau le dernier texte prononcé: \(lastText)")
    }
}

// Button style for improved interaction feedback
struct ScaleButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat
    var pressedColor: Color
    var normalColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : normalColor)
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

@MainActor
struct ControlButtonsView: View {
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var userModel: UserModel
    @Binding var recognizedText: String
    @Binding var showPhraseManager: Bool
    @Binding var speakTask: Task<Void, Never>?
    @State private var showUsageSettings: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced speak button at the top
            SpeakControlButton(
                text: recognizedText,
                isLoading: speechService.isLoading,
                onSpeak: {
                    guard !recognizedText.isEmpty else { return }
                    speechService.speakText(recognizedText)
                    recognizedText = ""
                }
            )
            
            // Enhanced repeat button
            RepeatControlButton(
                lastText: speechService.lastSpokenText,
                isLoading: speechService.isLoading,
                onRepeat: {
                    guard !speechService.lastSpokenText.isEmpty else { return }
                    speechService.speakText(speechService.lastSpokenText)
                }
            )
            
            // Clear text button
            Button(action: {
                recognizedText = ""
                speakTask?.cancel()
            }) {
                HStack {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18))
                    Text("Effacer le texte")
                        .font(.title2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            .disabled(speechService.isLoading || recognizedText.isEmpty)
            
            // Handwriting button removed as it's not useful for this app
            
            // Bouton pour ouvrir la gestion des phrases prédéfinies
            Button(action: {
                showPhraseManager = true
            }) {
                HStack {
                    Text("Gérer les phrases")
                        .font(.title2)
                    Image(systemName: "list.bullet")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            
            // Bouton paramètres de confidentialité - hidden when auth is skipped
            if !AppConfig.Features.skipAuthentication {
                Button(action: {
                    showUsageSettings = true
                }) {
                    HStack {
                        Text("Confidentialité")
                            .font(.title2)
                        Image(systemName: "lock.shield")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
                .overlay(alignment: .topTrailing) {
                    if UsageLogManager.shared.pendingLogsCount > 0 {
                        Text("\(UsageLogManager.shared.pendingLogsCount)")
                            .font(.caption)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .offset(x: 5, y: -5)
                    }
                }
            }
            
            // Bouton de déconnexion - hidden when auth is skipped
            if !AppConfig.Features.skipAuthentication {
                Button(action: {
                    userModel.signOut()
                }) {
                    HStack {
                        Text("Déconnexion")
                            .font(.title2)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(10)
                }
                .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            }
            
            // Espace flexible pour pousser les informations utilisateur vers le bas
            Spacer()
            
            // Informations utilisateur en bas de la colonne de gauche
            if let userName = userModel.userName {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.footnote)
                        .fontWeight(.medium)
                    
                    if let userEmail = userModel.userEmail {
                        Text(userEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("ID: \(userModel.userId ?? "Non disponible")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, alignment: .leading)
        .sheet(isPresented: $showUsageSettings) {
            UsageSettingsView()
        }
    }
}