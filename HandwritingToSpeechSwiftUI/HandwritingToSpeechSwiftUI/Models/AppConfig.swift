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

    // Gradium TTS Configuration
    struct Gradium {
        /// Gradium TTS WebSocket endpoint (EU region)
        static let apiEndpoint = "wss://eu.api.gradium.ai/api/speech/tts"

        /// Default voice ID for French (Leo)
        static let defaultVoiceId = "axlOaUiFyOZhy4nv"

        /// Output format for audio (PCM 24kHz Int16 Mono)
        static let outputFormat = "pcm"

        /// Request timeout in seconds
        static let timeout: TimeInterval = 15.0

        /// Keychain key for storing Gradium API key
        static let keychainKey = "gradium_api_key"

        /// Chunk size in bytes for streaming audio data (4KB optimal for smooth playback)
        static let streamingChunkSize = 4096
    }

    // Voice Selection Configuration (Story 1.3)
    struct VoiceConfig {
        /// UserDefaults key for persisting voice preference
        static let userDefaultsKey = "selected_voice_id"

        /// Default voice ID for French locale users (Leo)
        static let defaultVoiceId = "axlOaUiFyOZhy4nv"

        /// Available Gradium voices with display metadata
        static let availableVoices: [(id: String, name: String, description: String)] = [
            ("axlOaUiFyOZhy4nv", "Leo", "Voix masculine française")
        ]

        /// Sample text for voice preview
        static let previewTextTemplate = "Bonjour, je suis la voix %@"
    }

    // LLM Service Configuration (Story 3.1)
    struct LLM {
        /// Cerebras API endpoint (OpenAI-compatible)
        static let apiEndpoint = "https://api.cerebras.ai/v1/chat/completions"

        /// Default model for suggestions
        static let defaultModel = "qwen-3-235b-a22b-instruct-2507"

        /// Keychain key for storing LLM API key
        static let keychainKey = "llm_api_key"

        /// Request timeout in seconds (NFR-8: < 500ms target)
        static let timeout: TimeInterval = 10.0

        /// Maximum tokens for response
        static let maxTokens = 500

        /// Temperature for response creativity (0.0-1.5)
        static let temperature = 0.7

        /// Number of suggestions to generate
        static let suggestionCount = 4
    }
}
