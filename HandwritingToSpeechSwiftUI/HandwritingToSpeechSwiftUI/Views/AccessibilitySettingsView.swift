//
//  AccessibilitySettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 7.1: Accessibility Settings Screen (AC2, AC5, AC6)
//  Story 10.1: Fatigue Mode settings section (AC2)
//  Story 10.3: Replace placeholder with FatigueModeSettingsView
//  Story 11.2: Time-based phrases settings section (AC1)
//  Story 11.3: Scanning mode settings section (AC1)
//  Story 11.4: Replace placeholder with ScanningModeSettingsView
//  Sheet-style view for configuring Enhanced Accessibility mode
//

import SwiftUI
import UIKit

// Story 7.1 AC2: Accessibility settings screen with Enhanced Mode toggle
@MainActor
struct AccessibilitySettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    // Story 11.3 Task 5.2: ScanningModeSettings for toggle binding
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            List {
                // Story 7.1 AC2: Enhanced Accessibility toggle section
                Section {
                    Toggle(isOn: $accessibilitySettings.isEnhancedModeEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            // Story 7.1 AC2: Toggle label
                            Text("Accessibilité Renforcée")
                                .font(.title3)
                                .fontWeight(.medium)

                            // Story 7.1 AC2: Description text
                            Text("Agrandit les cibles tactiles, augmente le contraste, réduit les animations")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    // M1 Fix: Updated to iOS 17+ onChange syntax
                    .onChange(of: accessibilitySettings.isEnhancedModeEnabled) {
                        // Story 7.1 AC5: Haptic feedback on toggle (.medium)
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                    .frame(minHeight: 60)  // Story 7.1 AC2: 60pt minimum height
                    // Story 7.1 AC6: VoiceOver accessibility labels (French)
                    .accessibilityLabel("Accessibilité Renforcée")
                    .accessibilityHint("Agrandit les cibles tactiles, augmente le contraste, réduit les animations")
                    .accessibilityValue(accessibilitySettings.isEnhancedModeEnabled ? "Activé" : "Désactivé")
                } header: {
                    Text("Mode d'accessibilité")
                } footer: {
                    Text("Ce mode adapte l'interface pour les utilisateurs ayant des difficultés motrices. Les boutons seront agrandis à 80pt, les animations réduites, et le contraste augmenté.")
                }

                // Story 7.4 AC4: Confirmation dialogs toggle section
                Section {
                    Toggle(isOn: $accessibilitySettings.requireConfirmationDialogs) {
                        VStack(alignment: .leading, spacing: 4) {
                            // Story 7.4 AC4 Task 2.1: Toggle label
                            Text("Demander confirmation")
                                .font(.title3)
                                .fontWeight(.medium)

                            // Story 7.4 AC4 Task 2.2: Description text
                            Text("Affiche un dialogue avant les actions destructives (effacer, masquer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    // M1 Fix: Updated to iOS 17+ onChange syntax
                    .onChange(of: accessibilitySettings.requireConfirmationDialogs) {
                        // Haptic feedback on toggle (.medium)
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                    // Story 7.4 AC4 Task 2.3: Minimum 60pt height
                    .frame(minHeight: 60)
                    .accessibilityLabel("Demander confirmation")
                    .accessibilityHint("Active les dialogues de confirmation avant les actions destructives")
                    .accessibilityValue(accessibilitySettings.requireConfirmationDialogs ? "Activé" : "Désactivé")
                } header: {
                    Text("Sécurité")
                } footer: {
                    Text("Lorsque cette option est activée, une confirmation sera demandée avant d'effacer le texte ou de masquer les suggestions.")
                }

                // Story 10.1 AC2: Fatigue Mode settings section
                // Task 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
                Section {
                    // Story 10.1 Task 3.2: Toggle for fatigue mode
                    Toggle(isOn: $accessibilitySettings.isFatigueModeEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activer le mode fatigue")
                                .font(.title3)
                                .fontWeight(.medium)

                            Text("Interface simplifiée avec gros boutons pour les moments de fatigue intense")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    // Story 10.1 Task 3.6: Haptic feedback on toggle change
                    // M1 Fix: Updated to iOS 17+ onChange syntax
                    .onChange(of: accessibilitySettings.isFatigueModeEnabled) {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                    // Story 10.1 Task 3.4: Minimum 60pt height
                    .frame(minHeight: 60)
                    // Story 10.1 Task 3.5: French accessibility labels
                    .accessibilityLabel("Activer le mode fatigue")
                    .accessibilityHint("Active l'interface simplifiée pour les moments de fatigue intense")
                    .accessibilityValue(accessibilitySettings.isFatigueModeEnabled ? "Activé" : "Désactivé")

                    // Story 10.3 Task 5.1, 5.2: NavigationLink to FatigueModeSettingsView
                    NavigationLink {
                        FatigueModeSettingsView()
                            .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Personnaliser le mode fatigue")
                                    .font(.title3)
                                    .fontWeight(.medium)

                                Text("Choisir les messages affichés en mode fatigue")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        // Story 10.1 Task 3.4: Minimum 60pt height
                        .frame(minHeight: 60)
                    }
                    // Story 10.1 Task 3.5: French VoiceOver accessibility labels
                    .accessibilityLabel("Personnaliser le mode fatigue")
                    .accessibilityHint("Ouvre la configuration des messages du mode fatigue")
                } header: {
                    // Story 10.1 Task 3.1: Section header
                    Text("Mode Fatigue")
                } footer: {
                    Text("Le mode fatigue offre une interface épurée avec seulement quelques boutons essentiels pour communiquer rapidement lorsque vous êtes très fatigué.")
                }

                // Story 9.3 AC1: Emergency messages configuration section
                // Task 5.1, 5.2: NavigationLink with icon and label
                Section {
                    NavigationLink {
                        EmergencyMessagesSettingsView()
                            .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            // Task 5.2: Icon
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundColor(.red)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Messages d'urgence")
                                    .font(.title3)
                                    .fontWeight(.medium)

                                Text("Personnaliser les 4 messages du panneau d'urgence")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        // Task 5.3: Minimum 60pt height
                        .frame(minHeight: 60)
                    }
                    // Task 5.4: French VoiceOver accessibility labels (AC6)
                    .accessibilityLabel("Messages d'urgence")
                    .accessibilityHint("Ouvre la configuration des messages du panneau d'urgence")
                } header: {
                    Text("Urgence")
                }

                // Story 11.2 Task 4: Time-based phrases settings section (AC1)
                // Task 4.1: New Section for "Suggestions contextuelles"
                Section {
                    // Task 4.2: NavigationLink to TimeBasedPhrasesSettingsView
                    NavigationLink {
                        TimeBasedPhrasesSettingsView()
                            .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            // Task 4.3: clock.badge.fill icon with blue color
                            Image(systemName: "clock.badge.fill")
                                .font(.title2)
                                .foregroundColor(.blue)

                            // Task 4.4: Label and description
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Phrases du moment")
                                    .font(.title3)
                                    .fontWeight(.medium)

                                Text("Personnaliser les phrases suggérées selon l'heure")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        // Task 4.5: Minimum 60pt height
                        .frame(minHeight: 60)
                    }
                    // Task 4.5: French VoiceOver accessibility labels
                    .accessibilityLabel("Phrases du moment")
                    .accessibilityHint("Ouvre la configuration des phrases suggérées selon l'heure de la journée")
                } header: {
                    // Task 4.1: Section header
                    Text("Suggestions contextuelles")
                } footer: {
                    Text("Personnalisez les phrases suggérées automatiquement selon l'heure de la journée (matin, midi, soir, nuit).")
                }

                // Story 11.3 Task 5: Scanning Mode settings section (AC1)
                // Task 5.1: New Section "Mode Scanning"
                Section {
                    // Task 5.2: Toggle for scanning mode
                    Toggle(isOn: $scanningSettings.isEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activer le mode scanning")
                                .font(.title3)
                                .fontWeight(.medium)

                            // Task 5.3: Description text
                            Text("Les boutons s'illuminent tour à tour. Tapez pour sélectionner.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    // Haptic feedback on toggle change
                    // M1 Fix: Updated to iOS 17+ zero-parameter onChange syntax for consistency
                    .onChange(of: scanningSettings.isEnabled) {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }
                    // Task 5.5: Minimum height
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                    // Task 5.6: French VoiceOver accessibility labels
                    .accessibilityLabel("Activer le mode scanning")
                    .accessibilityHint("Les boutons s'illuminent tour à tour. Tapez n'importe où pour sélectionner.")
                    .accessibilityValue(scanningSettings.isEnabled ? "Activé" : "Désactivé")

                    // Story 11.4 Task 6: NavigationLink to ScanningModeSettingsView
                    NavigationLink {
                        ScanningModeSettingsView()
                            .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.purple)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Configurer le scanning")
                                    .font(.title3)
                                    .fontWeight(.medium)

                                Text("Vitesse, direction, retour sonore")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    .accessibilityLabel("Configurer le scanning")
                    .accessibilityHint("Ouvre la configuration de la vitesse, direction et comportement du scanning")
                } header: {
                    // Task 5.1: Section header
                    Text("Mode Scanning")
                } footer: {
                    Text("Le mode scanning permet aux utilisateurs à mobilité très réduite de sélectionner des options en tapant n'importe où lorsque l'élément souhaité est surligné.")
                }
            }
            .listStyle(.insetGrouped)
            // Story 7.1 AC2: Header "Accessibilité"
            .navigationTitle("Accessibilité")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Story 7.1 AC2: Close button
                    // M1 Note (Code Review): Toolbar buttons follow iOS HIG patterns and cannot
                    // guarantee 60pt height via frame modifiers. This is acceptable as toolbar
                    // buttons are accessible by default per Apple's Human Interface Guidelines.
                    Button(action: {
                        // Story 7.1 AC5: Haptic feedback on close (.light for navigation)
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        onDismiss()
                    }) {
                        Text("Fermer")
                            .fontWeight(.semibold)
                    }
                    // Story 7.1 AC6: French accessibility label
                    .accessibilityLabel("Fermer")
                    .accessibilityHint("Ferme les réglages d'accessibilité")
                }
            }
        }
    }
}

// MARK: - Story 10.3 Task 5.3: FatigueModeSettingsPlaceholder DELETED
// Dead code cleanup - replaced by FatigueModeSettingsView in FatigueModeSettingsView.swift

// MARK: - Preview
#Preview {
    AccessibilitySettingsView(onDismiss: {})
        .environmentObject(AccessibilitySettings())
}
