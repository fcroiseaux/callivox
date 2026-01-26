import SwiftUI

/// Voice selection screen allowing users to preview and select their preferred TTS voice (Story 1.3)
struct VoiceSelectionView: View {
    @EnvironmentObject var speechService: SpeechService

    var body: some View {
        List {
            Section {
                ForEach(AppConfig.VoiceConfig.availableVoices, id: \.id) { voice in
                    VoiceRow(
                        voice: voice,
                        isSelected: speechService.selectedVoiceId == voice.id,
                        isPreviewing: speechService.isPreviewingVoice,
                        onPreview: { speechService.previewVoice(voice.id) },
                        onSelect: { speechService.selectVoice(voice.id) }
                    )
                }
            } header: {
                Text("Voix disponibles")
            } footer: {
                Text("Appuyez sur une voix pour l'apercevoir, puis confirmez votre choix.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Sélection de la voix")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Individual row for a voice option with preview and selection capability
private struct VoiceRow: View {
    let voice: (id: String, name: String, description: String)
    let isSelected: Bool
    let isPreviewing: Bool
    let onPreview: () -> Void
    let onSelect: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(voice.name)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)

                Text(voice.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if isPreviewing {
                ProgressView()
                    .scaleEffect(0.8)
                    .accessibilityLabel("Aperçu en cours")
            } else {
                Button(action: onPreview) {
                    Image(systemName: "play.circle")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Apercevoir la voix \(voice.name)")
                .accessibilityHint("Joue un échantillon de cette voix")
            }

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                    .accessibilityLabel("Voix sélectionnée")
            } else {
                Button(action: onSelect) {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Sélectionner la voix \(voice.name)")
                .accessibilityHint("Définit cette voix comme votre préférence")
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(voice.name), \(voice.description)")
        .accessibilityValue(isSelected ? "Sélectionnée" : "Non sélectionnée")
        .accessibilityHint("Appuyez pour apercevoir ou sélectionner cette voix")
    }
}

#Preview {
    NavigationView {
        VoiceSelectionView()
            .environmentObject(SpeechService.shared)
    }
}
