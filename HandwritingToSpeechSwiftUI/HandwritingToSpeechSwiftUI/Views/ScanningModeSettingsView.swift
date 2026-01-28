//
//  ScanningModeSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.4: Scanning Mode Configuration Screen
//  Allows users to configure scanning speed, direction, and behavior.
//  Pattern: Follows FatigueModeSettingsView.swift exactly.
//

import SwiftUI
import UIKit

// MARK: - Story 11.4 Task 4: ScanningModeSettingsView (AC1, AC2, AC4)

/// Story 11.4 AC1: Configuration screen for scanning mode settings
@MainActor
struct ScanningModeSettingsView: View {
    // Task 4.3: EnvironmentObject for accessibility settings
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Task 4.4: ObservedObject for scanning settings
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared

    // Task 5.1: State for test mode
    @State private var isTestModeActive: Bool = false

    // Task 4.11: State for reset confirmation dialog
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        List {
            // Task 4.5: AC1, AC2 - Scan speed picker section
            Section {
                Picker("Vitesse", selection: $scanningSettings.scanSpeed) {
                    ForEach(ScanSpeed.allCases, id: \.self) { speed in
                        Text(speed.displayName).tag(speed)
                    }
                }
                .pickerStyle(.segmented)
                // M2 Learning: iOS 17+ onChange syntax
                .onChange(of: scanningSettings.scanSpeed) {
                    // Haptic feedback on selection change
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                // Task 4.9: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Vitesse de scanning")
                .accessibilityValue(scanningSettings.scanSpeed.displayName)
                .accessibilityHint("Choisir la durée d'affichage sur chaque bouton")
            } header: {
                Text("Vitesse de scanning")
            } footer: {
                Text("Durée d'affichage sur chaque bouton avant de passer au suivant.")
            }

            // Task 4.6: AC1 - Scan direction picker section
            Section {
                Picker("Direction", selection: $scanningSettings.scanDirection) {
                    ForEach(ScanDirection.allCases, id: \.self) { dir in
                        Text(dir.displayName).tag(dir)
                    }
                }
                .pickerStyle(.menu)
                // M2 Learning: iOS 17+ onChange syntax
                .onChange(of: scanningSettings.scanDirection) {
                    // Haptic feedback on selection change
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                // Task 4.9: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Direction du scanning")
                .accessibilityValue(scanningSettings.scanDirection.displayName)
                .accessibilityHint("Choisir le mode de défilement du scanning")
            } header: {
                Text("Direction")
            } footer: {
                Text(scanningSettings.scanDirection.accessibilityDescription)
            }

            // Task 4.7: AC1 - Behavior toggles section
            Section {
                // Auto-restart toggle
                Toggle(isOn: $scanningSettings.autoRestart) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Redémarrage automatique")
                            .font(.headline)
                        Text("Recommence après un cycle complet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // M2 Learning: iOS 17+ onChange syntax
                .onChange(of: scanningSettings.autoRestart) {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                // Task 4.9: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Redémarrage automatique")
                .accessibilityHint("Recommence le scanning après un cycle complet")
                // L3 Learning: Accessibility value for state
                .accessibilityValue(scanningSettings.autoRestart ? "Activé" : "Désactivé")

                // Sound feedback toggle
                Toggle(isOn: $scanningSettings.soundFeedbackEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Retour sonore")
                            .font(.headline)
                        Text("Émet un son lors du changement de sélection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // M2 Learning: iOS 17+ onChange syntax
                .onChange(of: scanningSettings.soundFeedbackEnabled) {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                // Task 4.9: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Retour sonore")
                .accessibilityHint("Émet un son subtil lors du changement de bouton surligné")
                // L3 Learning: Accessibility value for state
                .accessibilityValue(scanningSettings.soundFeedbackEnabled ? "Activé" : "Désactivé")
            } header: {
                Text("Comportement")
            }

            // Task 4.8: AC4 - Test mode button section
            Section {
                Button(action: {
                    // Haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    isTestModeActive = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle")
                            .font(.title2)
                            .foregroundColor(.purple)

                        Text("Tester le scanning")
                            .font(.headline)

                        Spacer()
                    }
                    // Task 4.9: Minimum height based on accessibility mode
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Tester le scanning")
                .accessibilityHint("Ouvre un aperçu pour tester les paramètres actuels")
                .accessibilityAddTraits(.isButton)
            } header: {
                Text("Aperçu")
            } footer: {
                Text("Testez les paramètres actuels avec des boutons de démonstration.")
            }

            // Task 4.11: Reset to defaults button section
            Section {
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Text("Réinitialiser par défaut")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    // Task 4.9: Minimum height based on accessibility mode
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
                // Task 4.10: French VoiceOver labels
                .accessibilityLabel("Réinitialiser par défaut")
                .accessibilityHint("Restaure tous les paramètres de scanning à leurs valeurs par défaut")
                .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Scanning")
        .navigationBarTitleDisplayMode(.large)
        // Task 5.3: Show test mode as sheet
        .sheet(isPresented: $isTestModeActive) {
            ScanningTestPreviewView(isPresented: $isTestModeActive)
                .environmentObject(accessibilitySettings)
        }
        // Task 4.11: Reset confirmation dialog
        .alert("Réinitialiser les paramètres ?", isPresented: $showResetConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Réinitialiser", role: .destructive) {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                scanningSettings.resetToDefaults()
            }
        } message: {
            Text("La vitesse, la direction et les autres paramètres seront restaurés à leurs valeurs par défaut.")
        }
    }
}

// MARK: - Story 11.4 Task 5: ScanningTestPreviewView (AC4)

/// Story 11.4 AC4: Test mode preview showing scanning behavior
@MainActor
struct ScanningTestPreviewView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject private var controller = ScanningModeController.shared
    @ObservedObject private var settings = ScanningModeSettings.shared

    // Task 5.2: Sample test items
    private let testItems = ["Oui", "Non", "Aide", "Merci"]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Test du mode scanning")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 24)

            Text("Les boutons s'illuminent selon vos paramètres")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Current settings display
            HStack(spacing: 16) {
                SettingIndicator(
                    icon: "speedometer",
                    label: settings.scanSpeed.displayName
                )
                SettingIndicator(
                    icon: "arrow.left.arrow.right",
                    label: settings.scanDirection.displayName
                )
            }
            .padding(.top, 8)

            Spacer()

            // Task 5.2: Test buttons grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Array(testItems.enumerated()), id: \.offset) { index, item in
                    TestButton(
                        text: item,
                        isHighlighted: index == controller.currentHighlightedIndex,
                        // L2 Fix: Pass accessibility button height for Enhanced Mode
                        buttonHeight: accessibilitySettings.buttonHeight
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Pause/Resume indicator
            if controller.isPaused {
                Text("Scanning en pause - tapez pour reprendre")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.bottom, 8)
            }

            // Task 5.5: Dismiss button (minimum 60pt height)
            Button(action: {
                controller.stopScanning()
                isPresented = false
            }) {
                Text("Terminé")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: max(60, accessibilitySettings.buttonHeight))
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .accessibilityLabel("Terminé")
            .accessibilityHint("Ferme l'aperçu et enregistre les paramètres")
        }
        // Task 5.4: Connect to controller for live demonstration
        // H1 Fix: Always use startScanningForTest which bypasses isEnabled check
        .onAppear {
            controller.startScanningForTest(itemCount: testItems.count)
        }
        .onDisappear {
            controller.stopScanning()
        }
        // Task 5.6: Handle tap to resume if paused
        .contentShape(Rectangle())
        .onTapGesture {
            if controller.isPaused {
                controller.resumeScanning()
            }
        }
    }
}

/// Settings indicator for test preview header
private struct SettingIndicator: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}

/// Individual test button with scanning highlight
/// L2 Fix: Made private - only used within this file for test preview
/// L2 Fix (Code Review): Accept buttonHeight for Enhanced Accessibility Mode
private struct TestButton: View {
    let text: String
    let isHighlighted: Bool
    let buttonHeight: CGFloat

    var body: some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            // L2 Fix: Use accessibility-aware height (minimum 80pt for test buttons)
            .frame(height: max(80, buttonHeight))
            .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHighlighted ? Color.yellow : Color.clear, lineWidth: 4)
            )
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            .accessibilityLabel(text)
            .accessibilityValue(isHighlighted ? "Surligné" : "")
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ScanningModeSettingsView()
            .environmentObject(AccessibilitySettings())
    }
}
