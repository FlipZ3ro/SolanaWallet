import Foundation
import Security

// MARK: - Keychain Manager

final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Save

    func save(key: String, data: Data, service: String = AppConstants.Keychain.service) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func save(key: String, string: String, service: String = AppConstants.Keychain.service) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        try save(key: key, data: data, service: service)
    }

    // MARK: - Retrieve

    func retrieve(key: String, service: String = AppConstants.Keychain.service) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.retrievalFailed(status)
        }

        return data
    }

    func retrieveString(key: String, service: String = AppConstants.Keychain.service) throws -> String {
        let data = try retrieve(key: key, service: service)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        return string
    }

    // MARK: - Delete

    func delete(key: String, service: String = AppConstants.Keychain.service) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Update

    func update(key: String, data: Data, service: String = AppConstants.Keychain.service) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.updateFailed(status)
        }
    }

    // MARK: - Check Existence

    func exists(key: String, service: String = AppConstants.Keychain.service) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case retrievalFailed(OSStatus)
    case deleteFailed(OSStatus)
    case updateFailed(OSStatus)
    case dataConversionFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .retrievalFailed(let status):
            return "Failed to retrieve from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .updateFailed(let status):
            return "Failed to update keychain: \(status)"
        case .dataConversionFailed:
            return "Failed to convert data"
        }
    }
}
