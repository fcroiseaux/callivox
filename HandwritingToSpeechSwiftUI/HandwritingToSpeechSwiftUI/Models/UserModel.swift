import Foundation
import AuthenticationServices
import UIKit

// API Response structure matching backend's AuthResponseDTO
struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let user: User?
    let message: String?
    let error: String?
    let isNewUser: Bool?  // Added to indicate if user was just created
    
    struct User: Codable {
        let id: String
        let email: String
        let name: String
        let provider: String
        let createdAt: String
        let lastLoginAt: String
        let usageCount: Int?  // Added to track usage statistics
    }
}

// User info structure for Apple Sign In
struct AppleUserInfo: Codable {
    let firstName: String?
    let lastName: String?
}

// Request structure matching backend's AppleLoginDTO
struct AppleLoginRequest: Codable {
    let identityToken: String
    let user: AppleUserInfo?
    
    init(identityToken: String, user: AppleUserInfo?) {
        self.identityToken = identityToken
        self.user = user
    }
}

// API service for backend communication
class APIService {
    static let shared = APIService()
    
    private let baseURL = AppConfig.API.baseURL
    private var authToken: String? {
        return KeychainManager.getAuthToken()
    }
    
    private init() {}
    
    func authenticateWithApple(identityToken: String, user: AppleUserInfo?, completion: @escaping (Result<AuthResponse, Error>) -> Void) {
        // Check master bypass flag first
        if AppConfig.API.bypassServerAPI || AppConfig.Features.useMockAuth {
            // Simulate successful authentication in development
            let mockUser = AuthResponse.User(
                id: "mock-user-123",
                email: "mock@example.com",
                name: [user?.firstName, user?.lastName].compactMap { $0 }.joined(separator: " "),
                provider: "apple",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                lastLoginAt: ISO8601DateFormatter().string(from: Date()),
                usageCount: 0
            )
            
            let mockResponse = AuthResponse(
                success: true,
                token: "mock-token-for-testing",
                user: mockUser,
                message: nil,
                error: nil,
                isNewUser: false
            )
            
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(.success(mockResponse))
            }
            return
        }
        
        // Print the full URL for debugging
        let fullURL = "\(baseURL)/auth/apple/mobile"
        print("Attempting to connect to: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let requestData = AppleLoginRequest(identityToken: identityToken, user: user)
        
        guard let jsonData = try? JSONEncoder().encode(requestData) else {
            completion(.failure(NSError(domain: "APIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = AppConfig.API.timeout
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Log HTTP status for debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response: \(httpResponse.statusCode)")
                
                // If we get a 404, it's likely the endpoint doesn't exist
                if httpResponse.statusCode == 404 {
                    print("Endpoint not found: \(url.absoluteString)")
                    completion(.failure(NSError(domain: "APIService", code: 404, userInfo: [NSLocalizedDescriptionKey: "API endpoint not found"])))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            // Debug: print raw response
            if let rawString = String(data: data, encoding: .utf8) {
                print("API Response: \(rawString)")
                
                // Check if we're getting HTML instead of JSON
                if rawString.contains("<html") || rawString.contains("<!DOCTYPE") {
                    print("Received HTML instead of JSON - likely a server configuration issue or wrong endpoint")
                    completion(.failure(NSError(domain: "APIService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Server returned HTML instead of JSON"])))
                    return
                }
                
                // Handle error response with statusCode
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                    // Create a failed response without attempting to parse as AuthResponse
                    let errorResponse = AuthResponse(
                        success: false,
                        token: nil,
                        user: nil,
                        message: "Server error: HTTP \(httpResponse.statusCode)",
                        error: rawString,
                        isNewUser: false
                    )
                    completion(.success(errorResponse))
                    return
                }
            }
            
            do {
                let decoder = JSONDecoder()
                // No date decoding strategy needed as we're using String instead of Date
                let authResponse = try decoder.decode(AuthResponse.self, from: data)
                completion(.success(authResponse))
            } catch {
                print("Decoding error: \(error)")
                
                // Create a failed response when we can't decode the server response
                let errorResponse = AuthResponse(
                    success: false,
                    token: nil,
                    user: nil,
                    message: "Failed to decode server response",
                    error: error.localizedDescription,
                    isNewUser: false
                )
                completion(.success(errorResponse))
            }
        }.resume()
    }
    
    // Helper method to add auth token to requests
    func authorizedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.timeoutInterval = AppConfig.API.timeout
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    // Generic request method for any API endpoint
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // Check if we should bypass the API
        if AppConfig.API.bypassServerAPI {
            print("Bypassing API request to \(endpoint) - using mock response")
            
            // Create a mock success response - this assumes a simple success response structure
            // You will need to customize this based on your expected response types
            if let mockResponse = createMockResponse(for: T.self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(.success(mockResponse))
                }
            } else {
                let error = NSError(domain: "APIService", code: -100, userInfo: [NSLocalizedDescriptionKey: "Could not create mock response for this type"])
                completion(.failure(error))
            }
            return
        }
        
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request: URLRequest
        if requiresAuth {
            request = authorizedRequest(url: url)
        } else {
            request = URLRequest(url: url)
            request.timeoutInterval = AppConfig.API.timeout
        }
        
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            guard let jsonData = try? JSONEncoder().encode(body) else {
                completion(.failure(NSError(domain: "APIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
                return
            }
            request.httpBody = jsonData
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "APIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                // No date decoding strategy needed as we're using String instead of Date
                let response = try decoder.decode(T.self, from: data)
                completion(.success(response))
            } catch {
                #if DEBUG
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Decoding error: \(error)\nRaw response: \(rawString)")
                }
                #endif
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Helper method to create mock responses for bypassed API calls
    private func createMockResponse<T: Decodable>(for type: T.Type) -> T? {
        // This is a simple implementation that works for AuthResponse
        // For other response types, you would need to add specific implementations
        
        if T.self == AuthResponse.self {
            // Generate a consistent mock user
            let userId = "mock-user-123"
            let email = "user-\(userId)@callivox.example.com" 
            let mockUser = AuthResponse.User(
                id: userId,
                email: email,
                name: "Mock User",
                provider: "apple",
                createdAt: ISO8601DateFormatter().string(from: Date()),
                lastLoginAt: ISO8601DateFormatter().string(from: Date()),
                usageCount: 0
            )
            
            let mockResponse = AuthResponse(
                success: true,
                token: "mock-token-for-testing",
                user: mockUser,
                message: nil,
                error: nil,
                isNewUser: false
            )
            
            return mockResponse as? T
        }
        
        // For simple success/failure responses
        // You would need to customize this based on your app's response models
        if let successResponse = ["success": true] as? T {
            return successResponse
        }
        
        return nil
    }
}

// Créez un modèle d'utilisateur pour stocker les informations d'authentification
class UserModel: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var userId: String?
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var authErrorMessage: String?
    @Published var isAuthenticating: Bool = false
    
    private let apiService = APIService.shared
    
    init() {
        // Check if authentication should be completely skipped
        if AppConfig.Features.skipAuthentication {
            print("Skip authentication enabled - bypassing all auth checks")
            self.isAuthenticated = true
            self.userId = "skipped-auth-user"
            self.userName = "Auth Skipped User"
            self.userEmail = "skipped-auth@example.com"
            return
        }
        
        // Check if we should force reauthorization
        if AppConfig.Features.forceReauthorization {
            print("Force reauthorization enabled - clearing stored auth state")
            KeychainManager.clearAuthData()
            self.isAuthenticated = false
            return
        }
        
        // Vérifier si l'utilisateur est déjà authentifié via le token dans le trousseau
        let hasToken = KeychainManager.getAuthToken() != nil
        self.isAuthenticated = hasToken
        
        if hasToken {
            // Si on a un token, on peut charger les données utilisateur depuis le keychain
            // Dans un environnement de production, on pourrait vérifier la validité du token ici
            do {
                if let data = try? KeychainManager.load(key: KeychainManager.AuthKeys.userId),
                   let userId = String(data: data, encoding: .utf8) {
                    self.userId = userId
                }
                
                if let data = try? KeychainManager.load(key: KeychainManager.AuthKeys.userName),
                   let userName = String(data: data, encoding: .utf8) {
                    self.userName = userName
                }
                
                if let data = try? KeychainManager.load(key: KeychainManager.AuthKeys.userEmail),
                   let userEmail = String(data: data, encoding: .utf8) {
                    self.userEmail = userEmail
                }
            }
        }
    }
    
    func authenticateWithApple(appleIDCredential: ASAuthorizationAppleIDCredential) {
        // Reset error state
        authErrorMessage = nil
        isAuthenticating = true
        
        // Extract user's name from Apple credentials
        let firstName = appleIDCredential.fullName?.givenName
        let lastName = appleIDCredential.fullName?.familyName
        let appleUserInfo = AppleUserInfo(firstName: firstName, lastName: lastName)
        
        // Check if we should bypass the API
        if AppConfig.API.bypassServerAPI {
            print("Bypassing API call - using mock authentication")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.isAuthenticating = false
                
                // Generate a consistent user ID based on Apple ID if available
                let userId = appleIDCredential.user
                
                // Create a user name from the Apple credential or use a fallback
                let name = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
                let displayName = name.isEmpty ? "Apple User" : name
                
                // Get email from Apple credential if available
                let email = appleIDCredential.email
                
                // For debugging, print the email we got from Apple
                print("Apple provided email: \(email ?? "nil")")
                
                // Use the email from Apple or a placeholder based on the user ID for consistency
                let userEmail = email ?? "\(appleIDCredential.user)@example.com"
                
                // Check keychain for previously stored email for this user
                if email == nil {
                    print("Email not provided by Apple - this is normal behavior for subsequent sign-ins")
                    print("Using formatted user ID as email: \(userEmail)")
                    
                    // Uncomment this block if you want to use stored email from keychain
                    /*
                    let userKey = "AppleUser_\(appleIDCredential.user)"
                    if let storedEmailData = try? KeychainManager.load(key: userKey),
                       let storedEmail = String(data: storedEmailData, encoding: .utf8) {
                        print("Found stored email in keychain: \(storedEmail)")
                        userEmail = storedEmail
                    } else {
                        print("No stored email found in keychain for this user")
                    }
                    */
                } else {
                    // Store the email in the keychain for future use
                    let userKey = "AppleUser_\(appleIDCredential.user)"
                    if let emailData = email?.data(using: .utf8) {
                        try? KeychainManager.save(key: userKey, data: emailData)
                        print("Saved email to keychain with key: \(userKey)")
                    }
                }
                
                // Mock token for development
                let mockToken = "mock-token-\(UUID().uuidString)"
                
                // Save to keychain
                try? KeychainManager.saveAuthToken(mockToken)
                
                if let userData = userId.data(using: .utf8) {
                    try? KeychainManager.save(key: KeychainManager.AuthKeys.userId, data: userData)
                }
                
                if let userData = displayName.data(using: .utf8) {
                    try? KeychainManager.save(key: KeychainManager.AuthKeys.userName, data: userData)
                }
                
                if let userData = userEmail.data(using: .utf8) {
                    try? KeychainManager.save(key: KeychainManager.AuthKeys.userEmail, data: userData)
                }
                
                // Update model properties
                self?.isAuthenticated = true
                self?.userId = userId
                self?.userName = displayName
                self?.userEmail = userEmail
            }
            return
        }
        
        // Get the identity token from Apple credential
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            authErrorMessage = "Impossible de récupérer le token d'identité Apple"
            isAuthenticating = false
            return
        }
        
        // Call backend API to authenticate
        apiService.authenticateWithApple(identityToken: identityToken, user: appleUserInfo) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                
                switch result {
                case .success(let response):
                    if response.success, let token = response.token, let user = response.user {
                        // Check if this is a new user
                        if let isNewUser = response.isNewUser, isNewUser {
                            print("Welcome to a new user! User account was created.")
                        }
                        
                        // Log usage count if available
                        if let usageCount = user.usageCount {
                            print("This user has used the app \(usageCount) times before")
                        }
                        
                        // Save auth data to keychain
                        try? KeychainManager.saveAuthToken(token)
                        
                        if let userData = user.id.data(using: .utf8) {
                            try? KeychainManager.save(key: KeychainManager.AuthKeys.userId, data: userData)
                        }
                        
                        if let userData = user.name.data(using: .utf8) {
                            try? KeychainManager.save(key: KeychainManager.AuthKeys.userName, data: userData)
                        }
                        
                        if let userData = user.email.data(using: .utf8) {
                            try? KeychainManager.save(key: KeychainManager.AuthKeys.userEmail, data: userData)
                        }
                        
                        // Update model properties
                        self?.isAuthenticated = true
                        self?.userId = user.id
                        self?.userName = user.name
                        self?.userEmail = user.email
                    } else {
                        self?.authErrorMessage = response.message ?? "Échec d'authentification"
                    }
                    
                case .failure(let error):
                    self?.authErrorMessage = "Erreur: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func signIn(userId: String, userName: String?, userEmail: String?) {
        self.isAuthenticated = true
        self.userId = userId
        self.userName = userName
        self.userEmail = userEmail
        
        // Cette méthode est gardée pour compatibilité avec le mode développement
        // mais en production, on devrait utiliser authenticateWithApple
        print("⚠️ Utilisation de la méthode de connexion locale - à utiliser uniquement en développement")
    }
    
    func signOut() {
        self.isAuthenticated = false
        self.userId = nil
        self.userName = nil
        self.userEmail = nil
        
        // Effacer les données d'authentification
        KeychainManager.clearAuthData()
    }
}
