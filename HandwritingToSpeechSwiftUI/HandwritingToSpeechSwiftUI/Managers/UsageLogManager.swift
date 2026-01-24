import Foundation
import CoreLocation
import UIKit

class UsageLogManager: NSObject, ObservableObject, CLLocationManagerDelegate, @unchecked Sendable {
    
    static let shared = UsageLogManager()
    
    private let apiService = APIService.shared
    
    // Make locationManager accessible to the view
    let locationManager = CLLocationManager()
    
    private let maxOfflineLogCount = 100
    private let offlineLogsKey = "offline_usage_logs"
    
    @Published var isLoggingEnabled = true
    @Published var isLocationEnabled = false
    @Published var pendingLogsCount = 0
    
    // Store last known location for logging
    private var lastKnownLocation: CLLocation?
    
    // Flag to track if we have already reported system-wide unavailability
    private var isLocationServicesUnavailable = false
    
    // Computed property to get the current authorization status in a backward-compatible way
    private var currentAuthorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14, *) {
            return locationManager.authorizationStatus
        } else {
            // For iOS 13 and below, use the class method
            return CLLocationManager.authorizationStatus()
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
        loadOfflineLogs()
        
        // Immediately check the current authorization status
        // This ensures we set isLocationEnabled correctly at startup
        DispatchQueue.main.async { [weak self] in
            self?.checkCurrentAuthorizationStatus()
        }
        
        // Register for app foreground notifications to re-check status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // lower accuracy for privacy
        locationManager.distanceFilter = 1000 // update only if user moves 1 km
        locationManager.pausesLocationUpdatesAutomatically = true
        
        print("Location Manager configured: accuracy=\(locationManager.desiredAccuracy), distanceFilter=\(locationManager.distanceFilter)")
    }
    
    // MARK: - App Foreground Handling
    
    @objc private func applicationWillEnterForeground() {
        print("📱 App returning to foreground - checking location status")
        
        // If we are authorized, we can safely restart location updates
        let status = currentAuthorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("✅ Location authorized - restarting location updates")
            locationManager.startUpdatingLocation()
        }
        
        checkCurrentAuthorizationStatus()
    }
    
    // MARK: - Checking / Requesting Authorization
    
    /// Checks (and updates) the current authorization status and `isLocationEnabled`.
    func checkCurrentAuthorizationStatus() {
        let status = currentAuthorizationStatus
        print("📱 Direct check of location status: \(status.rawValue)")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location is currently authorized")
            isLocationEnabled = true
            // Start receiving location updates
            locationManager.startUpdatingLocation()
            
            // If we have not received a location yet, request one
            if locationManager.location == nil && lastKnownLocation == nil {
                print("📍 No location available yet - requesting immediate update")
                locationManager.requestLocation()
            }
            
        case .denied:
            print("❌ Location access is currently denied")
            isLocationEnabled = false
            
        case .restricted:
            print("❌ Location access is restricted")
            isLocationEnabled = false
            
        case .notDetermined:
            print("⚠️ Location permission is not determined - requesting when in use")
            isLocationEnabled = false
            
            // Trigger the prompt if Info.plist is set up correctly
            if #available(iOS 14, *) {
                locationManager.requestWhenInUseAuthorization()
            } else {
                // On iOS 13 and below, same call
                locationManager.requestWhenInUseAuthorization()
            }
            
        @unknown default:
            print("❓ Unknown location authorization status")
            isLocationEnabled = false
        }
        
        // Notify the UI
        NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationChanged"), object: nil)
    }
    
    /// Request location permission explicitly (often called by a button).
    func requestLocationPermission() {
        // First check if location services are enabled system-wide
        if !CLLocationManager.locationServicesEnabled() {
            print("❌ Location services are disabled at the system level")
            isLocationEnabled = false
            
            // Notify UI
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("LocationServicesDisabled"), object: nil)
            }
            return
        }
        
        let status = currentAuthorizationStatus
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location already authorized, updating status")
            isLocationEnabled = true
            locationManager.startUpdatingLocation()
            
        case .denied:
            print("❌ Location permission denied - redirecting user to Settings")
            isLocationEnabled = false
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("LocationPermissionDenied"), object: nil)
                
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
        case .notDetermined:
            print("📱 Requesting location authorization (not determined)")
            locationManager.requestWhenInUseAuthorization()
            
            // Trigger location request to show system prompt if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if self?.currentAuthorizationStatus == .notDetermined {
                    print("📍 Still not determined after request - calling requestLocation() to force prompt")
                    self?.locationManager.requestLocation()
                }
            }
            
        case .restricted:
            print("⚠️ Location permission is restricted (e.g., parental controls), cannot request authorization")
            isLocationEnabled = false
            NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationChanged"), object: nil)
            
        @unknown default:
            print("❓ Unknown location authorization status")
            isLocationEnabled = false
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    /// iOS 14+ only. For iOS 13 or older, the old delegate method is used (below).
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📱 iOS14+ style authorization change callback")
        handleAuthorizationStatusChange(manager)
    }
    
    /// iOS 13 and older call this method instead of `locationManagerDidChangeAuthorization(_:)`.
    /// We simply forward the status change to the same internal handling function.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("📱 iOS13- style authorization change callback: status = \(status.rawValue)")
        handleAuthorizationStatusChange(manager)
    }
    
    /// Internal function to unify how we handle changes to authorization status
    private func handleAuthorizationStatusChange(_ manager: CLLocationManager) {
        let status = currentAuthorizationStatus
        print("📱 Authorization status changed to: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
            print("⏳ Location authorization: Not determined")
            isLocationEnabled = false
            
        case .restricted:
            print("⛔️ Location authorization: Restricted")
            isLocationEnabled = false
            
        case .denied:
            print("🚫 Location authorization: Denied")
            isLocationEnabled = false
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location authorization: Granted")
            isLocationEnabled = true
            manager.startUpdatingLocation()
            
        @unknown default:
            print("❓ Location authorization: Unknown status")
            isLocationEnabled = false
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationChanged"), object: nil)
    }
    
    /// Called when the location manager has new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("✅ Received location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            lastKnownLocation = location
            isLocationEnabled = true
            
            // If we only need location "when in use," we can stop updates to save battery
            if currentAuthorizationStatus == .authorizedWhenInUse {
                manager.stopUpdatingLocation()
                print("📍 Stopped continuous location updates to save battery")
            }
            
            // Notify that we have a new location
            NotificationCenter.default.post(name: NSNotification.Name("LocationReceived"), object: nil)
        }
    }
    
    /// Called when there is an error updating location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location manager error: \(error.localizedDescription)")
        
        let isSimulatorOrLocationNotSupported = error.localizedDescription.contains("L'opération n'a pas pu s'achever")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                print("⚠️ User denied location access (CLError.denied)")
                handleLocationDeniedOrUnavailable(isSimulator: isSimulatorOrLocationNotSupported)
                
            case .network:
                print("⚠️ Network error when getting location (CLError.network)")
                // Often temporary
                
            case .locationUnknown:
                print("⚠️ Location unknown - might just need more time (CLError.locationUnknown)")
                // Often temporary
                
            default:
                print("⚠️ Other location error code: \(clError.code.rawValue)")
                if isSimulatorOrLocationNotSupported {
                    print("🔍 Likely simulator or environment without location support")
                    handleLocationDeniedOrUnavailable(isSimulator: true)
                } else {
                    checkCurrentAuthorizationStatus()
                }
            }
        } else {
            // Some other kind of error
            if isSimulatorOrLocationNotSupported {
                print("🔍 Likely simulator or environment without location support")
                handleLocationDeniedOrUnavailable(isSimulator: true)
            } else {
                checkCurrentAuthorizationStatus()
            }
        }
    }
    
    private func handleLocationDeniedOrUnavailable(isSimulator: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isLocationEnabled = false
            NotificationCenter.default.post(name: NSNotification.Name("LocationAuthorizationChanged"), object: nil)
            
            // Check if location services are enabled system-wide
            if !CLLocationManager.locationServicesEnabled() {
                if !self.isLocationServicesUnavailable {
                    self.isLocationServicesUnavailable = true
                    NotificationCenter.default.post(name: NSNotification.Name("LocationServicesDisabled"), object: nil)
                    print("📱 System-wide Location Services are disabled. User must enable them in Settings.")
                }
            } else if isSimulator && !self.isLocationServicesUnavailable {
                // The user is probably in a simulator that does not have location support
                self.isLocationServicesUnavailable = true
                NotificationCenter.default.post(name: NSNotification.Name("LocationServicesUnavailable"), object: nil)
                print("📱 Location services are unavailable in the simulator or environment.")
            }
        }
    }
    
    // MARK: - Usage Logging
    
    func logSentenceUsage(_ sentence: String) {
        guard isLoggingEnabled else { return }
        
        // Re-check location authorization
        let status = currentAuthorizationStatus
        let locationAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
        
        if locationAuthorized && !isLocationEnabled {
            print("⚠️ Location authorized but not marked as enabled in app - correcting this")
            isLocationEnabled = true
            locationManager.startUpdatingLocation()
        }
        
        // Attempt to get a current location
        let currentLocation: CLLocation? = isLocationEnabled ? (locationManager.location ?? lastKnownLocation) : nil
        
        if currentLocation == nil && isLocationEnabled {
            print("📍 Location services enabled but no location - requesting an update")
            locationManager.requestLocation()
        }
        
        let log = UsageLog(sentence: sentence, location: currentLocation)
        
        submitLog(log)
    }
    
    /// Send a log to the server (or store it offline if not authenticated).
    private func submitLog(_ log: UsageLog) {
        guard let token = KeychainManager.getAuthToken() else {
            print("Usage logging: User not authenticated, saving offline")
            saveLogOffline(log)
            return
        }
        
        print("Usage logging: Submitting log for sentence: '\(log.sentence)'")
        
        Task {
            do {
                let dto = log.toDTO()
                let encoder = JSONEncoder()
                encoder.outputFormatting = .withoutEscapingSlashes
                let encodedLog = try encoder.encode(dto)
                
                guard let url = URL(string: "\(AppConfig.API.baseURL)/stats") else {
                    print("Usage logging: Invalid URL, saving offline")
                    saveLogOffline(log)
                    return
                }
                
                var request = apiService.authorizedRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = encodedLog
                
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Usage logging: Invalid HTTP response, saving offline")
                    saveLogOffline(log)
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    print("Usage logging: Log submitted successfully.")
                    // Attempt to send pending offline logs
                    if pendingLogsCount > 0 {
                        submitOfflineLogs()
                    }
                } else {
                    print("Usage logging: Server error \(httpResponse.statusCode), saving offline")
                    saveLogOffline(log)
                }
                
            } catch {
                print("Usage logging error: \(error.localizedDescription)")
                saveLogOffline(log)
            }
        }
    }
    
    // MARK: - Offline Log Management
    
    private func saveLogOffline(_ log: UsageLog) {
        var offlineLogs = getOfflineLogs()
        
        // Cap logs to prevent unbounded growth
        if offlineLogs.count >= maxOfflineLogCount {
            offlineLogs.removeFirst()
        }
        
        do {
            let logData = try JSONEncoder().encode(log)
            if let logString = String(data: logData, encoding: .utf8) {
                offlineLogs.append(logString)
                UserDefaults.standard.set(offlineLogs, forKey: offlineLogsKey)
                
                DispatchQueue.main.async {
                    self.pendingLogsCount = offlineLogs.count
                }
            }
        } catch {
            print("Error saving log offline: \(error.localizedDescription)")
        }
    }
    
    private func getOfflineLogs() -> [String] {
        UserDefaults.standard.stringArray(forKey: offlineLogsKey) ?? []
    }
    
    private func loadOfflineLogs() {
        let logs = getOfflineLogs()
        DispatchQueue.main.async {
            self.pendingLogsCount = logs.count
        }
    }
    
    /// Submit all stored offline logs to the server
    func submitOfflineLogs() {
        guard KeychainManager.getAuthToken() != nil else {
            print("Usage logging: Cannot submit offline logs - user not authenticated")
            return
        }
        
        let offlineLogs = getOfflineLogs()
        guard !offlineLogs.isEmpty else {
            print("Usage logging: No offline logs to submit")
            return
        }
        
        print("Usage logging: Submitting \(offlineLogs.count) offline logs")
        
        Task {
            var successCount = 0
            
            for logString in offlineLogs {
                do {
                    guard let logData = logString.data(using: .utf8),
                          let log = try? JSONDecoder().decode(UsageLog.self, from: logData) else {
                        print("Usage logging: Failed to decode offline log")
                        continue
                    }
                    
                    guard let url = URL(string: "\(AppConfig.API.baseURL)/stats") else {
                        print("Usage logging: Invalid URL for offline log submission")
                        continue
                    }
                    
                    let dto = log.toDTO()
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .withoutEscapingSlashes
                    let dtoData = try encoder.encode(dto)
                    
                    var request = apiService.authorizedRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = dtoData
                    
                    let (_, response) = try await URLSession.shared.data(for: request)
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        successCount += 1
                    }
                    
                } catch {
                    print("Error submitting offline log: \(error.localizedDescription)")
                    continue
                }
            }
            
            if successCount > 0 {
                print("Successfully submitted \(successCount) offline logs.")
                
                // Remove successfully submitted logs from disk
                if successCount == offlineLogs.count {
                    // All logs succeeded
                    UserDefaults.standard.removeObject(forKey: offlineLogsKey)
                    await MainActor.run {
                        pendingLogsCount = 0
                    }
                } else {
                    // Only some logs succeeded
                    let remainingLogs = Array(offlineLogs.dropFirst(successCount))
                    UserDefaults.standard.set(remainingLogs, forKey: offlineLogsKey)
                    await MainActor.run {
                        pendingLogsCount = remainingLogs.count
                    }
                }
            }
        }
    }
    
    func clearOfflineLogs() {
        UserDefaults.standard.removeObject(forKey: offlineLogsKey)
        DispatchQueue.main.async {
            self.pendingLogsCount = 0
        }
    }
}
