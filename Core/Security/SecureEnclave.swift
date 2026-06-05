import Foundation
import Security

// MARK: - Secure Enclave Manager

final class SecureEnclaveManager {
    static let shared = SecureEnclaveManager()

    private let accessControl: SecAccessControl

    private init() {
        // Create access control for secure enclave
        var error: Unmanaged<CFError>?
        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.privateKeyUsage, .biometryCurrentSet],
            &error
        ) else {
            fatalError("Failed to create access control: \(error?.takeRetainedValue().localizedDescription ?? "Unknown")")
        }
        self.accessControl = access
    }

    // MARK: - Generate Key

    func generateKey(tag: String) throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
                kSecAttrAccessControl as String: accessControl
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw SecureEnclaveError.keyGenerationFailed(error?.takeRetainedValue().localizedDescription ?? "Unknown")
        }

        return privateKey
    }

    // MARK: - Get Key

    func getKey(tag: String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            return nil
        }

        return (item as! SecKey)
    }

    // MARK: - Delete Key

    func deleteKey(tag: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureEnclaveError.keyDeletionFailed
        }
    }

    // MARK: - Sign Data

    func sign(data: Data, tag: String) throws -> Data {
        guard let privateKey = getKey(tag: tag) else {
            throw SecureEnclaveError.keyNotFound
        }

        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            &error
        ) else {
            throw SecureEnclaveError.signingFailed(error?.takeRetainedValue().localizedDescription ?? "Unknown")
        }

        return signature as Data
    }

    // MARK: - Verify Signature

    func verify(signature: Data, data: Data, publicKey: SecKey) -> Bool {
        return SecKeyVerifySignature(
            publicKey,
            .ecdsaSignatureMessageX962SHA256,
            data as CFData,
            signature as CFData,
            nil
        )
    }

    // MARK: - Get Public Key

    func getPublicKey(tag: String) -> SecKey? {
        guard let privateKey = getKey(tag: tag) else {
            return nil
        }
        return SecKeyCopyPublicKey(privateKey)
    }

    // MARK: - Export Public Key Data

    func exportPublicKeyData(tag: String) throws -> Data {
        guard let publicKey = getPublicKey(tag: tag) else {
            throw SecureEnclaveError.keyNotFound
        }

        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            throw SecureEnclaveError.exportFailed(error?.takeRetainedValue().localizedDescription ?? "Unknown")
        }

        return data as Data
    }

    // MARK: - Key Exists

    func keyExists(tag: String) -> Bool {
        return getKey(tag: tag) != nil
    }
}

// MARK: - Secure Enclave Errors

enum SecureEnclaveError: LocalizedError {
    case keyGenerationFailed(String)
    case keyNotFound
    case keyDeletionFailed
    case signingFailed(String)
    case verificationFailed
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .keyGenerationFailed(let message):
            return "Failed to generate key: \(message)"
        case .keyNotFound:
            return "Key not found in Secure Enclave."
        case .keyDeletionFailed:
            return "Failed to delete key from Secure Enclave."
        case .signingFailed(let message):
            return "Failed to sign data: \(message)"
        case .verificationFailed:
            return "Signature verification failed."
        case .exportFailed(let message):
            return "Failed to export public key: \(message)"
        }
    }
}
