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
    // M2 Fix: Use @ObservedObject for shared singleton (consistent with other service patterns)
    @ObservedObject private var suggestionService = SuggestionService.shared
    // Interlocutor listening service for STT transcription
    @ObservedObject private var listeningService = InterlocutorListeningService.shared
    @EnvironmentObject var userModel: UserModel
    // Story 7.1 Task 5.1: AccessibilitySettings for app-wide enhanced mode reactivity
    // Used in Stories 7.2, 7.3 to apply enhanced accessibility when toggle changes
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    @State private var recognizedText: String = ""
    @State private var autoRead: Bool = false
    @State private var speakTask: Task<Void, Never>?
    @State private var showPhraseManager: Bool = false
    @State private var showUsageSettings: Bool = false
    // Story 9.1 Task 4.1: State for emergency panel presentation
    @State private var showEmergencyPanel: Bool = false
    // Story 10.2 Task 4.1: State for fatigue mode persistence check on app launch
    @State private var showFatigueModeFromPersistence: Bool = false

    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // Story 9.1 Task 3.1, 3.2: Emergency button at top-right (AC1, AC2)
            // Positioned above OfflineIndicatorView for consistent visibility
            HStack {
                Spacer()
                EmergencyButtonView(onTap: {
                    // Story 9.1 Task 4.3: Set state to show emergency panel
                    showEmergencyPanel = true
                })
                .padding(.trailing, 16)
                .padding(.top, 8)
            }
            // Story 9.1 Task 3.3: Ensure visibility above other elements
            .zIndex(1)

            // Offline indicator at top of screen (Story 2.1: AC2, AC3)
            // M1 Fix: Removed redundant animation modifier - animation is handled in OfflineIndicatorView
            // M2 Fix: OfflineIndicatorView now handles its own NetworkMonitor observation
            OfflineIndicatorView()
                .padding(.top, 8)

            HStack(alignment: .top) {
                // Colonne de gauche : boutons principaux - Utilisant ControlButtonsView existant
                ControlButtonsView(
                    recognizedText: $recognizedText,
                    showPhraseManager: $showPhraseManager,
                    speakTask: $speakTask
                )

                // Colonne de droite : contenu principal amélioré
                // iPad Fix: ScrollView pour permettre le défilement quand le contenu dépasse l'écran
                ScrollView {
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
                        // InvincibleVoice: Unfreeze suggestions after speaking
                        suggestionService.unfreezeSuggestions()
                    }
                )

                // Story 3.3 + 4.2 + InvincibleVoice: AI Suggestions section
                VStack(alignment: .leading, spacing: 8) {
                    // Generate suggestions button
                    HStack {
                        Spacer()
                        GenerateSuggestionsButton(currentText: recognizedText)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Story 4.2: Quick guidance controls (AC1, AC6)
                    GuidanceControlsView()
                        .padding(.top, 4)

                    // InvincibleVoice: Quick keyword chips (shows when keywords available)
                    KeywordChipsView()

                    // Suggestion display (shows when suggestions available)
                    SuggestionView(
                        currentText: recognizedText,
                        onSuggestionSelected: { _ in
                            // Clear text field after selection (TTS already triggered by SuggestionView)
                            recognizedText = ""
                            // InvincibleVoice: Unfreeze suggestions after speaking
                            suggestionService.unfreezeSuggestions()
                        },
                        onEditSuggestion: { suggestion in
                            // InvincibleVoice: Copy suggestion to text field for editing
                            recognizedText = suggestion
                        }
                    )
                }

                // Quick selection view with toggles
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        SpeechToggleView(autoRead: $autoRead)
                        Spacer()
                        // Listening toggle for interlocutor transcription
                        ListeningToggleButton(listeningService: listeningService)
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
            } // End ScrollView (iPad Fix)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        } // End outer VStack (Story 2.1)

            // Transcription overlay for interlocutor listening
            TranscriptionOverlayView(listeningService: listeningService)
        } // End ZStack
        // Fenêtre modale de gestion des phrases prédéfinies
        .sheet(isPresented: $showPhraseManager) {
            PhrasesListView()
        }
        // Story 9.2: Emergency panel presentation (fullScreenCover for urgency)
        // AC1-7: Full emergency panel with critical message buttons
        .fullScreenCover(isPresented: $showEmergencyPanel) {
            EmergencyPanelView(onDismiss: { showEmergencyPanel = false })
                .environmentObject(accessibilitySettings)
        }
        // Story 10.2 Task 4.3: Fatigue mode persistence - show on app launch if enabled (AC5)
        // Task 4.4: Inject environmentObjects
        // H1 Fix (Code Review): Single source of truth - ContentView is the only presenter
        .fullScreenCover(isPresented: $showFatigueModeFromPersistence) {
            FatigueModeView(onDismiss: {
                showFatigueModeFromPersistence = false
            })
            .environmentObject(accessibilitySettings)
            .environmentObject(speechService)
        }
        .onAppear {
            loadData()
            // Story 10.2 Task 4.2: Check persisted fatigue mode state on app launch (AC5)
            showFatigueModeFromPersistence = accessibilitySettings.isFatigueModeEnabled
        }
        // H1 Fix (Code Review): Watch isFatigueModeEnabled for changes from sidebar button
        // This ensures ContentView presents FatigueModeView regardless of activation source
        .onChange(of: accessibilitySettings.isFatigueModeEnabled) { oldValue, newValue in
            if newValue && !showFatigueModeFromPersistence {
                // Fatigue mode was activated (e.g., from sidebar), present the view
                showFatigueModeFromPersistence = true
            } else if !newValue && showFatigueModeFromPersistence {
                // Fatigue mode was deactivated, dismiss the view
                showFatigueModeFromPersistence = false
            }
        }
        .onDisappear {
            cancelTasks()
        }
        .alert("Erreur", isPresented: $speechService.showError) {
            Button("OK") { speechService.showError = false }
        } message: {
            Text(speechService.errorMessage)
        }
        // Story 3.3: Error alert for suggestion service
        // Use Binding wrapper since showError is private(set)
        .alert("Erreur IA", isPresented: Binding(
            get: { suggestionService.showError },
            set: { _ in suggestionService.dismissError() }
        )) {
            Button("OK") { suggestionService.dismissError() }
        } message: {
            Text(suggestionService.errorMessage)
        }
        // Error alert for listening service (STT)
        .alert("Erreur Écoute", isPresented: Binding(
            get: { listeningService.showError },
            set: { _ in listeningService.dismissError() }
        )) {
            Button("OK") { listeningService.dismissError() }
        } message: {
            Text(listeningService.errorMessage)
        }
        .onChange(of: recognizedText) { oldValue, newValue in
            handleTextChange(oldValue: oldValue, newValue: newValue)
        }
        // Disable listening during TTS playback to avoid feedback loop
        .onChange(of: speechService.isLoading) { oldValue, newValue in
            if newValue {
                // TTS started, stop listening
                listeningService.stopListening()
            }
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

        // InvincibleVoice: Unfreeze suggestions when text is cleared
        if corrected.isEmpty && !oldValue.isEmpty {
            suggestionService.unfreezeSuggestions()
        }

        if autoRead && !corrected.isEmpty {
            speakTask = Task {
                try? await Task.sleep(for: .seconds(3))

                guard !Task.isCancelled else { return }

                speechService.speakText(corrected)
                recognizedText = ""
                // InvincibleVoice: Unfreeze suggestions after auto-read
                suggestionService.unfreezeSuggestions()
            }
        }
    }
    
    private func cancelTasks() {
        speakTask?.cancel()
        speakTask = nil
    }
}
