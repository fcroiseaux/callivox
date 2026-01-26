//
//  LLMSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.1: LLM Service Integration
//  Settings view for configuring the LLM (AI suggestions) service.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI

/// Settings view for LLM (AI suggestions) service configuration (Story 3.1, AC4)
///
/// Allows users to:
/// - Enter and save their LLM API key securely to Keychain
/// - Optionally change the API endpoint (defaults to Cerebras)
/// - Test the connection to verify configuration
struct LLMSettingsView: View {

    // MARK: - State Properties

    @State private var apiKey: String = ""
    @State private var customEndpoint: String = ""
    @State private var useCustomEndpoint: Bool = false
    @State private var showSaveSuccess: Bool = false
    @State private var showSaveError: Bool = false
    @State private var saveErrorMessage: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: TestResult? = nil

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
                    .accessibilityLabel("Clé API LLM")
                    .accessibilityHint("Entrez votre clé API pour le service d'IA")
            } header: {
                Text("Clé API")
            } footer: {
                Text("Votre clé API est stockée de manière sécurisée dans le trousseau.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Custom Endpoint Section (Optional)
            Section {
                Toggle("Utiliser un endpoint personnalisé", isOn: $useCustomEndpoint)
                    .accessibilityHint("Activez pour utiliser un autre serveur que Cerebras")

                if useCustomEndpoint {
                    TextField("URL de l'endpoint", text: $customEndpoint)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .accessibilityLabel("URL de l'endpoint personnalisé")
                }
            } header: {
                Text("Endpoint (optionnel)")
            } footer: {
                if useCustomEndpoint {
                    Text("L'endpoint doit être compatible avec l'API OpenAI.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Par défaut: Cerebras (\(AppConfig.LLM.apiEndpoint))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
                .accessibilityHint("Vérifie que la clé API est valide")
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
        .navigationTitle("Service IA")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadConfiguration)
        .alert("Erreur", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: - Private Methods

    /// Loads existing configuration from Keychain on view appear
    private func loadConfiguration() {
        // Load API key if stored
        if let data = try? KeychainManager.load(key: AppConfig.LLM.keychainKey),
           let savedKey = String(data: data, encoding: .utf8) {
            apiKey = savedKey
        }

        // Load custom endpoint if stored
        if let endpointData = try? KeychainManager.load(key: "\(AppConfig.LLM.keychainKey)_endpoint"),
           let savedEndpoint = String(data: endpointData, encoding: .utf8),
           !savedEndpoint.isEmpty {
            customEndpoint = savedEndpoint
            useCustomEndpoint = true
        }
    }

    /// Saves the API key to Keychain (AC4: Store to Keychain)
    private func saveConfiguration() {
        guard !apiKey.isEmpty else { return }

        do {
            // Save API key to Keychain
            guard let keyData = apiKey.data(using: .utf8) else {
                throw LLMError.invalidApiKey
            }
            try KeychainManager.save(key: AppConfig.LLM.keychainKey, data: keyData)

            // Save custom endpoint if enabled
            if useCustomEndpoint && !customEndpoint.isEmpty {
                guard let endpointData = customEndpoint.data(using: .utf8) else {
                    throw LLMError.apiError(statusCode: 0, message: "URL invalide")
                }
                try KeychainManager.save(key: "\(AppConfig.LLM.keychainKey)_endpoint", data: endpointData)
            } else {
                // Remove custom endpoint if disabled
                try? KeychainManager.delete(key: "\(AppConfig.LLM.keychainKey)_endpoint")
            }

            // Show success feedback
            withAnimation {
                showSaveSuccess = true
            }

            // Hide success indicator after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }

            print("LLMSettingsView: Configuration saved successfully")
        } catch {
            saveErrorMessage = "Impossible de sauvegarder la configuration: \(error.localizedDescription)"
            showSaveError = true
            print("LLMSettingsView: Save error - \(error)")
        }
    }

    /// Tests the LLM connection with a simple request (AC4: Test connection button)
    private func testConnection() {
        guard !apiKey.isEmpty else { return }

        isTesting = true
        testResult = nil

        Task {
            do {
                // First save the current configuration (API key + custom endpoint if enabled)
                guard let keyData = apiKey.data(using: .utf8) else {
                    throw LLMError.invalidApiKey
                }
                try KeychainManager.save(key: AppConfig.LLM.keychainKey, data: keyData)

                // Save or remove custom endpoint based on toggle
                let endpointKey = "\(AppConfig.LLM.keychainKey)_endpoint"
                if useCustomEndpoint && !customEndpoint.isEmpty {
                    guard let endpointData = customEndpoint.data(using: .utf8) else {
                        throw LLMError.apiError(statusCode: 0, message: "URL invalide")
                    }
                    try KeychainManager.save(key: endpointKey, data: endpointData)
                } else {
                    try? KeychainManager.delete(key: endpointKey)
                }

                // Create provider and test with a simple prompt
                // Provider will now use custom endpoint if configured
                let provider = OpenAICompatibleLLMProvider()
                let suggestions = try await provider.generateSuggestions(
                    prompt: "Bonjour",
                    context: nil
                )

                // Success if we got any suggestions
                await MainActor.run {
                    isTesting = false
                    testResult = suggestions.isEmpty ? .failure("Aucune suggestion reçue") : .success
                }
            } catch let error as LLMError {
                await MainActor.run {
                    isTesting = false
                    // AC3: Show French error message with recovery suggestion
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
        LLMSettingsView()
    }
}
