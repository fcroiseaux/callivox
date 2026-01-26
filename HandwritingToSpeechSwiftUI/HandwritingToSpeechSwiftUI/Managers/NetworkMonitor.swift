import Foundation
import Network

/// NetworkMonitor provides centralized network connectivity monitoring for the app.
/// It uses NWPathMonitor to detect network status changes in real-time and publishes
/// the connection state for SwiftUI views and services to observe.
///
/// Usage:
/// - Access via `NetworkMonitor.shared` singleton
/// - Observe `isConnected` property for network state
/// - SwiftUI views can use `@ObservedObject var networkMonitor = NetworkMonitor.shared`
///
/// AC1: Detects network status changes in real-time via NWPathMonitor
/// AC4: Network check completes quickly (< 10ms) and doesn't block main thread
@MainActor
class NetworkMonitor: ObservableObject {
    /// Shared singleton instance
    static let shared = NetworkMonitor()

    /// Published property indicating current network connectivity status.
    /// `true` when network is available, `false` when offline.
    /// This property is updated asynchronously when network status changes.
    @Published private(set) var isConnected: Bool = true

    /// The underlying NWPathMonitor that detects network changes
    private let monitor = NWPathMonitor()

    /// Dedicated queue for network monitoring to avoid blocking main thread
    private let queue = DispatchQueue(label: "com.callivox.networkmonitor")

    /// Private initializer to enforce singleton pattern
    private init() {
        startMonitoring()
    }

    /// Starts the network path monitoring.
    /// Called automatically during initialization.
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            // Update isConnected on main actor to ensure thread safety
            // and proper SwiftUI binding updates
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    /// Cleanup: Cancel the monitor when the instance is deallocated.
    /// Note: Since this is a singleton, deinit is rarely called, but it's
    /// good practice to include proper cleanup.
    deinit {
        monitor.cancel()
    }
}
