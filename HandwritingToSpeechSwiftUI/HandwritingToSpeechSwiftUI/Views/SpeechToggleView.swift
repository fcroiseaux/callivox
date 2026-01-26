import SwiftUI

struct SpeechToggleView: View {
    @EnvironmentObject var speechService: SpeechService
    @Binding var autoRead: Bool
    @State private var showVoiceSelection: Bool = false

    /// Display name for the currently selected voice
    private var selectedVoiceName: String {
        AppConfig.VoiceConfig.availableVoices.first { $0.id == speechService.selectedVoiceId }?.name
            ?? speechService.selectedVoiceId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Gradium TTS toggle (Story 1.3: Primary voice option)
            Toggle(isOn: $speechService.useGradium) {
                Text(speechService.useGradium ? "Utiliser la voix Gradium" : "Utiliser la synthèse vocale d'Apple")
                    .font(.callout)
            }
            .disabled(!speechService.gradiumAvailable)
            .accessibilityLabel("Type de voix")
            .accessibilityHint(speechService.useGradium ?
                "Actuellement réglé sur la voix Gradium. Désactiver pour utiliser la voix Apple." :
                "Actuellement réglé sur la voix Apple. Activer pour utiliser la voix Gradium.")
            .accessibilityValue(speechService.useGradium ? "Voix Gradium" : "Voix Apple")

            // Voice selection button (Story 1.3: AC1)
            if speechService.gradiumAvailable {
                Button(action: { showVoiceSelection = true }) {
                    HStack {
                        Image(systemName: "waveform.circle")
                            .font(.body)
                        Text("Voix: \(selectedVoiceName)")
                            .font(.callout)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Sélection de la voix")
                .accessibilityHint("Ouvre l'écran de sélection de voix. Voix actuelle: \(selectedVoiceName)")
                .accessibilityValue(selectedVoiceName)
            }

            if !speechService.gradiumAvailable {
                Text("La voix Gradium n'est pas disponible. Configurez votre clé API dans les paramètres.")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .accessibilityLabel("Alerte: La voix Gradium n'est pas disponible")
            }

            Toggle("Lecture automatique", isOn: $autoRead)
                .accessibilityLabel("Lecture automatique")
                .accessibilityHint("Lorsque activé, le texte sera lu automatiquement après 3 secondes")
                .accessibilityValue(autoRead ? "Activé" : "Désactivé")
        }
        .padding(.horizontal)
        .sheet(isPresented: $showVoiceSelection) {
            NavigationView {
                VoiceSelectionView()
                    .environmentObject(speechService)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Fermer") {
                                showVoiceSelection = false
                            }
                        }
                    }
            }
        }
    }
}