import Foundation
import CoreLocation
import UIKit

/// Model representing a speech usage log entry for local storage
struct UsageLog: Codable {
    let id: String
    let sentence: String
    let timestamp: Date
    let location: Location?
    let deviceInfo: String
    
    struct Location: Codable {
        let lat: Double
        let lng: Double
    }
    
    init(sentence: String, location: CLLocation? = nil) {
        self.id = UUID().uuidString
        self.sentence = sentence
        self.timestamp = Date()
        
        // Use real location if provided
        if let location = location {
            self.location = Location(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            )
            print("📍 Using real device location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        } else {
            self.location = nil
            print("📍 No location data available for this log")
        }
        
        // Create basic device info string
        var deviceInfoComponents = [String]()
        deviceInfoComponents.append(UIDevice.current.model)
        deviceInfoComponents.append(UIDevice.current.systemName)
        deviceInfoComponents.append(UIDevice.current.systemVersion)
        self.deviceInfo = deviceInfoComponents.joined(separator: " - ")
    }
    
    /// Convert to DTO for server submission
    func toDTO() -> UsageLogDTO {
        return UsageLogDTO(
            sentence: self.sentence,
            location: self.location,
            deviceInfo: self.deviceInfo
        )
    }
}

/// DTO for server submission with sentence and location
struct UsageLogDTO: Encodable {
    let sentence: String
    let location: UsageLog.Location?
    let deviceInfo: String?
}

/// Response from the backend when submitting usage logs
struct LogSubmissionResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}