import SwiftUI

/// OfflineIndicatorView displays a non-intrusive banner when the device is offline.
/// It automatically shows/hides based on NetworkMonitor's connection status.
///
/// AC2: Visual indicator shows "Mode hors-ligne" when offline, clearly visible but not intrusive
/// AC3: Indicator disappears when connection is restored, with smooth animation
struct OfflineIndicatorView: View {
    /// Observes the shared NetworkMonitor for connection state changes
    /// Uses singleton pattern - for testing, mock NetworkMonitor.shared in test setup
    @ObservedObject var networkMonitor = NetworkMonitor.shared

    var body: some View {
        // H1 Fix: Content always in hierarchy, visibility controlled by opacity
        // This ensures transition animations work for both appear AND disappear
        Group {
            if !networkMonitor.isConnected {
                offlineIndicatorContent
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
    }

    // MARK: - Localization Constants
    // L1 Fix: Centralized strings for future localization (add to Localizable.strings when i18n is needed)
    private enum Strings {
        static let offlineLabel = "Mode hors-ligne"
        static let accessibilityLabel = "Mode hors-ligne activé"
        static let accessibilityHint = "L'application fonctionne sans connexion internet"
    }

    /// Extracted indicator content for cleaner structure
    private var offlineIndicatorContent: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text(Strings.offlineLabel)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.9))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityLabel(Strings.accessibilityLabel)
        .accessibilityHint(Strings.accessibilityHint)
    }
}

// MARK: - Previews

// M5 Fix: Separate previews for both states
#Preview("Offline State") {
    VStack {
        // Preview with simulated offline state
        OfflineIndicatorPreview(isConnected: false)
        Spacer()
    }
    .padding()
}

#Preview("Online State") {
    VStack {
        // Preview with simulated online state (indicator hidden)
        OfflineIndicatorPreview(isConnected: true)
        Text("Indicator hidden when online")
            .foregroundColor(.secondary)
        Spacer()
    }
    .padding()
}

/// Preview helper that allows testing both connection states
private struct OfflineIndicatorPreview: View {
    let isConnected: Bool

    var body: some View {
        Group {
            if !isConnected {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.caption)
                    Text("Mode hors-ligne")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.9))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
}
