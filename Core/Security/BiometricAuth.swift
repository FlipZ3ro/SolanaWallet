import Foundation
import LocalAuthentication

// MARK: - Biometric Auth Manager

@MainActor
final class BiometricAuthManager: ObservableObject {
    static let shared = BiometricAuthManager()

    @Published var isAvailable = false
    @Published var biometricType: BiometricType = .none
    @Published var isAuthenticated = false

    private let context = LAContext()

    enum BiometricType {
        case none
        case faceID
        case touchID
        case opticID
    }

    private init() {
        checkBiometricAvailability()
    }

    // MARK: - Check Availability

    func checkBiometricAvailability() {
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            isAvailable = false
            biometricType = .none
            return
        }

        isAvailable = true

        switch context.biometryType {
        case .faceID:
            biometricType = .faceID
        case .touchID:
            biometricType = .touchID
        case .opticID:
            biometricType = .opticID
        default:
            biometricType = .none
        }
    }

    // MARK: - Authenticate

    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            await MainActor.run {
                isAuthenticated = success
            }

            return success
        } catch {
            await MainActor.run {
                isAuthenticated = false
            }
            return false
        }
    }

    // MARK: - Authenticate for Transaction

    func authenticateForTransaction(amount: String, recipient: String) async -> Bool {
        let reason = "Confirm sending \(amount) SOL to \(recipient.truncatedAddress)"
        return await authenticate(reason: reason)
    }

    // MARK: - Authenticate for Widget Send

    func authenticateForWidgetSend(amount: String) async -> Bool {
        let reason = "Confirm sending \(amount) SOL from widget"
        return await authenticate(reason: reason)
    }

    // MARK: - Reset

    func reset() {
        context.invalidate()
        isAuthenticated = false
        checkBiometricAvailability()
    }
}

// MARK: - Biometric Auth Errors

enum BiometricAuthError: LocalizedError {
    case notAvailable
    case authenticationFailed
    case userCancel
    case userFallback
    case systemError
    case passcodeNotSet

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device."
        case .authenticationFailed:
            return "Biometric authentication failed."
        case .userCancel:
            return "Authentication was cancelled."
        case .userFallback:
            return "User chose to use password instead."
        case .systemError:
            return "A system error occurred."
        case .passcodeNotSet:
            return "Please set a passcode in Settings."
        }
    }
}
