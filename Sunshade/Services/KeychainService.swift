import Foundation
import Security

enum KeychainError: Error, LocalizedError {
    case duplicateItem
    case itemNotFound
    case unexpectedData
    case unhandledError(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .duplicateItem:
            return "Duplicate item in keychain"
        case .itemNotFound:
            return "Item not found in keychain"
        case .unexpectedData:
            return "Unexpected data format in keychain"
        case .unhandledError(let status):
            return "Unhandled keychain error: \(status)"
        }
    }
}

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    // MARK: - Constants
    private struct Keys {
        static let appleUserID = "appleUserID"
        static let authenticatedUser = "authenticatedUser"
    }
    
    private let serviceName = "com.sunshade.app.Sunshade"
    
    // MARK: - Generic Keychain Operations
    
    private func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item if it exists
        delete(key: key)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    private func load(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unhandledError(status: status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.unexpectedData
        }
        
        return data
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Authentication-Specific Methods
    
    func saveAppleUserID(_ userID: String) throws {
        guard let data = userID.data(using: .utf8) else {
            throw KeychainError.unexpectedData
        }
        try save(key: Keys.appleUserID, data: data)
    }
    
    func loadAppleUserID() throws -> String {
        let data = try load(key: Keys.appleUserID)
        guard let userID = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedData
        }
        return userID
    }
    
    func deleteAppleUserID() {
        delete(key: Keys.appleUserID)
    }
    
    func saveAuthenticatedUser(_ user: AuthenticatedUser) throws {
        let data = try JSONEncoder().encode(user)
        try save(key: Keys.authenticatedUser, data: data)
    }
    
    func loadAuthenticatedUser() throws -> AuthenticatedUser {
        let data = try load(key: Keys.authenticatedUser)
        return try JSONDecoder().decode(AuthenticatedUser.self, from: data)
    }
    
    func deleteAuthenticatedUser() {
        delete(key: Keys.authenticatedUser)
    }
    
    // MARK: - Clear All Authentication Data
    
    func clearAllAuthenticationData() {
        deleteAppleUserID()
        deleteAuthenticatedUser()
    }
    
    // MARK: - Keychain Status Check
    
    func hasStoredCredentials() -> Bool {
        do {
            _ = try loadAppleUserID()
            return true
        } catch {
            return false
        }
    }
}