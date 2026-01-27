//
//  AccessibilitySettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 7.1: Accessibility Settings Screen (AC2, AC5, AC6)
//  Sheet-style view for configuring Enhanced Accessibility mode
//

import SwiftUI
import UIKit

// Story 7.1 AC2: Accessibility settings screen with Enhanced Mode toggle
@MainActor
struct AccessibilitySettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
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
                    .onChange(of: accessibilitySettings.isEnhancedModeEnabled) { _ in
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

                // Placeholder section for future settings (Stories 7.2, 7.3, 7.4)
                // These will be added in subsequent stories:
                // - Story 7.2: Enlarged touch targets (80pt)
                // - Story 7.3: High contrast and reduced animations
                // - Story 7.4: Confirmation dialogs for destructive actions
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

// MARK: - Preview
#Preview {
    AccessibilitySettingsView(onDismiss: {})
        .environmentObject(AccessibilitySettings())
}
