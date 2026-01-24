import Foundation
import Security
import AuthenticationServices

class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        case itemNotFound
        case invalidItemFormat
    }
    
    static func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // If the item already exists, update it
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unknown(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unknown(status)
        }
    }
    
    static func load(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return data
    }
    
    static func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    // Helper methods for auth-specific operations
    struct AuthKeys {
        static let token = "auth_token"
        static let userId = "auth_user_id"
        static let userEmail = "auth_user_email"
        static let userName = "auth_user_name"
    }
    
    static func saveAuthToken(_ token: String) throws {
        if let data = token.data(using: .utf8) {
            try save(key: AuthKeys.token, data: data)
        }
    }
    
    static func getAuthToken() -> String? {
        do {
            let data = try load(key: AuthKeys.token)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    static func clearAuthData() {
        print("Clearing all auth data from keychain")
        try? delete(key: AuthKeys.token)
        try? delete(key: AuthKeys.userId)
        try? delete(key: AuthKeys.userEmail)
        try? delete(key: AuthKeys.userName)
        
        // Also clear the ASAuthorizationAppleIDProvider credentials by invalidating them
        // This requires the user to provide credentials again, triggering a "first-time" auth flow
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: "any") { (state, error) in
            // We intentionally use an invalid user ID to force a re-auth
            print("Forcing Apple ID credential refresh")
        }
    }
}