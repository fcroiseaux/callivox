import SwiftUI
import AVFoundation

// ScaleButtonStyle is now imported from ControlButtonsView

// Text input area with floating speak button
@MainActor
struct TextInputWithSpeakButton: View {
    @Binding var text: String
    var onSpeak: () -> Void
    
    // Floating action button component
    private var floatingButton: some View {
        ZStack {
            // Placeholder button to maintain layout
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.green))
            }
            .opacity(0)
            .disabled(true)
            
            // Actual button that appears when text is not empty
            if !text.isEmpty {
                Button(action: onSpeak) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.green))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(ScaleButtonStyle(scaleAmount: 0.9, pressedColor: .clear, normalColor: .clear))
                .accessibilityLabel("Lire immédiatement")
            }
        }
        .padding()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Texte à prononcer")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    TextEditor(text: $text)
                        .font(.system(size: 24))
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        )
                        .frame(minHeight: min(150, geometry.size.height * 0.5))
                        .accessibilityLabel("Zone de texte")
                    
                    floatingButton
                        .animation(.spring(response: 0.3), value: !text.isEmpty)
                }
            }
            .frame(minHeight: 150)
            .padding(.horizontal)
        }
    }
}

@MainActor
struct ContentView: View {
    @StateObject private var speechService = SpeechService.shared
    @StateObject private var presetManager = PresetSentenceManager.shared
    @EnvironmentObject var userModel: UserModel
    
    @State private var recognizedText: String = ""
    @State private var autoRead: Bool = false
    @State private var speakTask: Task<Void, Never>?
    @State private var showPhraseManager: Bool = false
    @State private var showUsageSettings: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            // Colonne de gauche : boutons principaux - Utilisant ControlButtonsView existant
            ControlButtonsView(
                recognizedText: $recognizedText,
                showPhraseManager: $showPhraseManager,
                speakTask: $speakTask
            )
            
            // Colonne de droite : contenu principal amélioré
            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("CalliVox")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                // Improved text input area with immediate speak button
                TextInputWithSpeakButton(
                    text: $recognizedText,
                    onSpeak: {
                        speechService.speakText(recognizedText)
                        recognizedText = ""
                    }
                )
                
                // Quick selection view with toggles
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        SpeechToggleView(autoRead: $autoRead)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Enhanced shortcut section
                VStack(alignment: .leading, spacing: 8) {
                    if !presetManager.selectedPresets.isEmpty {
                        Text("Phrases rapides")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 5)
                            
                        SpeechShortcutsView()
                    }
                }
            }
            .padding(.vertical)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        // Fenêtre modale de gestion des phrases prédéfinies
        .sheet(isPresented: $showPhraseManager) {
            PhrasesListView()
        }
        .onAppear {
            loadData()
        }
        .onDisappear {
            speechService.stopAvailabilityTimer()
            cancelTasks()
        }
        .alert("Erreur", isPresented: $speechService.showError) {
            Button("OK") { speechService.showError = false }
        } message: {
            Text(speechService.errorMessage)
        }
        .onChange(of: recognizedText) { oldValue, newValue in
            handleTextChange(oldValue: oldValue, newValue: newValue)
        }
        .environmentObject(speechService)
        .environmentObject(presetManager)
    }
    
    private func loadData() {
        // This function is called when the view appears
        // Try to submit any pending usage logs if user is authenticated
        if userModel.isAuthenticated && UsageLogManager.shared.pendingLogsCount > 0 {
            UsageLogManager.shared.submitOfflineLogs()
        }
    }
    
    private func handleTextChange(oldValue: String, newValue: String) {
        speakTask?.cancel()
        
        let corrected = speechService.correctText(newValue)
        if corrected != newValue {
            recognizedText = corrected
        }
        
        if autoRead && !corrected.isEmpty {
            speakTask = Task {
                try? await Task.sleep(for: .seconds(3))
                
                guard !Task.isCancelled else { return }
                
                speechService.speakText(corrected)
                recognizedText = ""
            }
        }
    }
    
    private func cancelTasks() {
        speakTask?.cancel()
        speakTask = nil
    }
}
