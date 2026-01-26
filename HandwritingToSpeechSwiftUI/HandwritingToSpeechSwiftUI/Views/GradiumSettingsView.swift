//
//  GradiumSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Settings view for configuring the Gradium TTS service.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI

/// Settings view for Gradium TTS service configuration
///
/// Allows users to:
/// - Enter and save their Gradium API key securely to Keychain
/// - Test the connection to verify configuration
struct GradiumSettingsView: View {

    // MARK: - State Properties

    @State private var apiKey: String = ""
    @State private var showSaveSuccess: Bool = false
    @State private var showSaveError: Bool = false
    @State private var saveErrorMessage: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: TestResult? = nil
    @State private var showDeleteConfirmation: Bool = false

    private enum TestResult {
        case success
        case failure(String)
    }

    // MARK: - Body

    var body: some View {
        List {
            // API Key Section
            Section {
                SecureField("Clé API", text: $apiKey)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .accessibilityLabel("Clé API Gradium")
                    .accessibilityHint("Entrez votre clé API pour le service de synthèse vocale")
            } header: {
                Text("Clé API Gradium")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Votre clé API est stockée de manière sécurisée dans le trousseau.")
                    Link("Obtenez votre clé sur gradium.ai", destination: URL(string: "https://gradium.ai")!)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Endpoint")
                    Text(AppConfig.Gradium.apiEndpoint)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Endpoint: \(AppConfig.Gradium.apiEndpoint)")

                HStack {
                    Text("Voix par défaut")
                    Spacer()
                    Text(AppConfig.Gradium.defaultVoiceId.capitalized)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Voix par défaut: \(AppConfig.Gradium.defaultVoiceId)")
            } header: {
                Text("Configuration")
            } footer: {
                Text("Sans clé API Gradium, l'app utilise la synthèse vocale iOS (AVFoundation) en mode hors-ligne.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Actions Section
            Section {
                // Save Button
                Button(action: saveConfiguration) {
                    HStack {
                        Text("Enregistrer")
                        Spacer()
                        if showSaveSuccess {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .disabled(apiKey.isEmpty)
                .accessibilityLabel("Enregistrer la configuration")
                .accessibilityHint("Sauvegarde la clé API dans le trousseau")

                // Test Connection Button
                Button(action: testConnection) {
                    HStack {
                        Text("Tester la connexion")
                        Spacer()
                        if isTesting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else if let result = testResult {
                            switch result {
                            case .success:
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            case .failure:
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .disabled(apiKey.isEmpty || isTesting)
                .accessibilityLabel("Tester la connexion")
                .accessibilityHint("Vérifie que la clé API est valide en faisant une requête de test")

                // Delete Key Button
                if !apiKey.isEmpty {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        HStack {
                            Text("Supprimer la clé API")
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }
                    .accessibilityLabel("Supprimer la clé API")
                    .accessibilityHint("Supprime la clé API du trousseau")
                }
            } header: {
                Text("Actions")
            }

            // Test Result Section (shown only after test)
            if let result = testResult {
                Section {
                    switch result {
                    case .success:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Connexion réussie")
                                .foregroundColor(.green)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Test réussi, connexion établie")
                    case .failure(let message):
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Échec de connexion")
                                    .foregroundColor(.red)
                            }
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Test échoué: \(message)")
                    }
                } header: {
                    Text("Résultat du test")
                }
            }
        }
        .navigationTitle("Service TTS")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadConfiguration)
        .alert("Erreur", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
        .confirmationDialog(
            "Supprimer la clé API ?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                deleteConfiguration()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("L'application utilisera la synthèse vocale iOS (AVFoundation) en mode hors-ligne.")
        }
    }

    // MARK: - Private Methods

    /// Loads existing configuration from Keychain on view appear
    private func loadConfiguration() {
        if let data = try? KeychainManager.load(key: AppConfig.Gradium.keychainKey),
           let savedKey = String(data: data, encoding: .utf8) {
            apiKey = savedKey
        }
    }

    /// Saves the API key to Keychain
    private func saveConfiguration() {
        guard !apiKey.isEmpty else { return }

        do {
            guard let keyData = apiKey.data(using: .utf8) else {
                throw TTSError.invalidApiKey
            }
            try KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: keyData)

            withAnimation {
                showSaveSuccess = true
            }

            Task {
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    withAnimation {
                        showSaveSuccess = false
                    }
                }
            }

            print("GradiumSettingsView: Configuration saved successfully")
        } catch {
            saveErrorMessage = "Impossible de sauvegarder la configuration: \(error.localizedDescription)"
            showSaveError = true
            print("GradiumSettingsView: Save error - \(error)")
        }
    }

    /// Deletes the API key from Keychain
    private func deleteConfiguration() {
        do {
            try KeychainManager.delete(key: AppConfig.Gradium.keychainKey)
            apiKey = ""
            testResult = nil
            print("GradiumSettingsView: Configuration deleted")
        } catch {
            saveErrorMessage = "Impossible de supprimer la clé: \(error.localizedDescription)"
            showSaveError = true
        }
    }

    /// Tests the Gradium connection with a simple TTS request
    private func testConnection() {
        guard !apiKey.isEmpty else { return }

        isTesting = true
        testResult = nil

        Task {
            do {
                // First save the current API key
                guard let keyData = apiKey.data(using: .utf8) else {
                    throw TTSError.invalidApiKey
                }
                try KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: keyData)

                // Create provider and test with a simple text
                let provider = GradiumTTSProvider()
                let stream = try await provider.synthesize(
                    text: "Test",
                    voice: AppConfig.Gradium.defaultVoiceId
                )

                // Just verify we can get at least one chunk
                var receivedData = false
                for try await chunk in stream {
                    if !chunk.isEmpty {
                        receivedData = true
                        break
                    }
                }

                await MainActor.run {
                    isTesting = false
                    testResult = receivedData ? .success : .failure("Aucune donnée audio reçue")
                }
            } catch let error as TTSError {
                await MainActor.run {
                    isTesting = false
                    let message = error.errorDescription ?? "Erreur inconnue"
                    let suggestion = error.recoverySuggestion ?? ""
                    testResult = .failure("\(message)\n\(suggestion)".trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    testResult = .failure(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        GradiumSettingsView()
    }
}
