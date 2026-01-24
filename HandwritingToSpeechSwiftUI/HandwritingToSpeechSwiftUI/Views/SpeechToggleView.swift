import SwiftUI

struct SpeechToggleView: View {
    @EnvironmentObject var speechService: SpeechService
    @Binding var autoRead: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $speechService.useElevenLabs) {
                Text(speechService.useElevenLabs ? "Utiliser la synthèse vocale d'Apple" : "Utiliser la voix d'Odile")
                    .font(.callout)
            }
            .disabled(!speechService.elevenLabsAvailable)
            .accessibilityLabel("Type de voix")
            .accessibilityHint(speechService.useElevenLabs ? 
                "Actuellement réglé sur la voix d'Odile. Désactiver pour utiliser la voix Apple." : 
                "Actuellement réglé sur la voix Apple. Activer pour utiliser la voix d'Odile.")
            .accessibilityValue(speechService.useElevenLabs ? "Voix d'Odile" : "Voix Apple")
            
            if !speechService.elevenLabsAvailable && speechService.useElevenLabs == false {
                Text("La voix d'Odile n'est pas disponible actuellement")
                    .font(.caption)
                    .foregroundColor(.red)
                    .accessibilityLabel("Alerte: La voix d'Odile n'est pas disponible")
            }
            
            Toggle("Lecture automatique", isOn: $autoRead)
                .accessibilityLabel("Lecture automatique")
                .accessibilityHint("Lorsque activé, le texte sera lu automatiquement après 3 secondes")
                .accessibilityValue(autoRead ? "Activé" : "Désactivé")
        }
        .padding(.horizontal)
    }
}