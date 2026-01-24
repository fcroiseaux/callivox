import Foundation

struct AppConfig {
    // API Configuration
    struct API {
        // If you need to use a different endpoint, modify this line:
        static let baseURL = "https://api.callivox.app" // Production server
        
        // Uncomment and use the configuration below if you need different URLs based on build configuration
        /*
        #if DEBUG && !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        static let baseURL = "https://api.callivox.app" // Use production server on real devices even in DEBUG
        #elseif DEBUG
        static let baseURL = "http://localhost:8080" // Development server for simulator
        #else
        static let baseURL = "https://api.callivox.app" // Production server
        #endif
        */
        
        static let timeout: TimeInterval = 30.0
        
        // Master switch to bypass all API calls
        static let bypassServerAPI = true // Set to true to completely skip all backend API calls
    }
    
    // Feature Flags
    struct Features {
        // For testing purposes, enable mock auth for all builds
        static let useMockAuth = false // Use mock auth regardless of build configuration
        
        // Force reauthorization on every app start (for testing email retrieval)
        static let forceReauthorization = false // Set to true to simulate first-time auth on each app start
        
        // Skip authentication completely (will bypass all auth flows)
        static let skipAuthentication = true // Set to true to completely bypass authentication
        
        // Uncomment and use the configuration below for normal operation
        /*
        #if DEBUG && !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        static let useMockAuth = false // Use real auth on physical devices
        #elseif DEBUG
        static let useMockAuth = false // Set to true to bypass real authentication in DEBUG
        #else
        static let useMockAuth = false // Never use mock in production
        #endif
        */
    }
}
