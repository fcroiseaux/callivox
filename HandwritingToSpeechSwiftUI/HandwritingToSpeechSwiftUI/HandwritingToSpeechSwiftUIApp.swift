//
//  HandwritingToSpeechSwiftUIApp.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by Fabrice CROISEAUX on 28/01/2025.
//

import SwiftUI
import CoreLocation

@main
struct HandwritingToSpeechSwiftUIApp: App {
    @StateObject private var userModel = UserModel()
    // Story 7.1 Task 4.5: AccessibilitySettings instance for environment injection
    @StateObject private var accessibilitySettings = AccessibilitySettings()
    // Story 11.1 Task 5.1: TimeBasedPhraseSettings instance for environment injection
    @StateObject private var timeBasedPhraseSettings = TimeBasedPhraseSettings.shared
    
    init() {
        // Print app configuration status for debugging
        #if DEBUG
        print("Running in DEBUG mode")
        #else
        print("Running in RELEASE mode")
        #endif
        
        print("API settings:")
        print("- Base URL: \(AppConfig.API.baseURL)")
        print("- Bypass Server API: \(AppConfig.API.bypassServerAPI)")
        
        print("Feature flags:")
        print("- Use Mock Auth: \(AppConfig.Features.useMockAuth)")
        print("- Force Reauthorization: \(AppConfig.Features.forceReauthorization)")
        print("- Skip Authentication: \(AppConfig.Features.skipAuthentication)")
        
        // Skip location checks at launch to avoid warnings
        print("App initialized - location services will be checked in background")
    }
    
    var body: some Scene {
        WindowGroup {
            if userModel.isAuthenticated {
                ContentView()
                    .environmentObject(userModel)
                    // Story 7.1 Task 4.4: Inject AccessibilitySettings for app-wide access
                    .environmentObject(accessibilitySettings)
                    // Story 11.1 Task 5.2: Inject TimeBasedPhraseSettings for time-based suggestions
                    .environmentObject(timeBasedPhraseSettings)
                    .onAppear {
                        // Only check location status, don't request permission automatically
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            UsageLogManager.shared.checkCurrentAuthorizationStatus()
                        }
                    }
            } else {
                AppleSignInView()
                    .environmentObject(userModel)
            }
        }
    }
}
