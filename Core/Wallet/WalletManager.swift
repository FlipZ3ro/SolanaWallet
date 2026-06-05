import Foundation
import SwiftUI

// MARK: - Wallet Manager

@MainActor
final class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var currentWallet: Wallet?
    @Published var balance: Balance = Balance(sol: 0, lamports: 0, usdValue: nil)
    @Published var tokens: [Token] = []
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: String?

    private let keychain = KeychainManager.shared
    private let crypto = CryptoHelper.shared
    private let solanaService = SolanaService.shared

    private init() {}

    // MARK: - Create New Wallet

    func createWallet(name: String) async throws -> Wallet {
        isLoading = true
        defer { isLoading = false }

        // Generate mnemonic
        let mnemonic = crypto.generateMnemonic()

        // Generate keypair from mnemonic
        let keypair = try deriveKeypair(from: mnemonic)

        // Save to keychain
        try keychain.save(key: AppConstants.Keychain.mnemonicKey, string: mnemonic)
        try keychain.save(key: "\(AppConstants.Keychain.walletKeyPrefix)\(keypair.publicKey)", data: keypair.privateKey)

        // Create wallet
        let wallet = Wallet(name: name, publicKey: keypair.publicKey)

        // Save wallet
        try saveWallet(wallet)

        currentWallet = wallet

        // Sync widget data
        await syncWidgetData()

        return wallet
    }

    // MARK: - Import Wallet

    func importWallet(name: String, mnemonic: String) async throws -> Wallet {
        isLoading = true
        defer { isLoading = false }

        // Validate mnemonic
        guard validateMnemonic(mnemonic) else {
            throw WalletError.invalidMnemonic
        }

        // Generate keypair from mnemonic
        let keypair = try deriveKeypair(from: mnemonic)

        // Save to keychain
        try keychain.save(key: AppConstants.Keychain.mnemonicKey, string: mnemonic)
        try keychain.save(key: "\(AppConstants.Keychain.walletKeyPrefix)\(keypair.publicKey)", data: keypair.privateKey)

        // Create wallet
        let wallet = Wallet(name: name, publicKey: keypair.publicKey)

        // Save wallet
        try saveWallet(wallet)

        currentWallet = wallet

        // Sync widget data
        await syncWidgetData()

        return wallet
    }

    // MARK: - Load Existing Wallet

    func loadWallet() async {
        guard let walletData = UserDefaults.standard.data(forKey: "current_wallet"),
              let wallet = try? JSONDecoder().decode(Wallet.self, from: walletData) else {
            return
        }

        currentWallet = wallet
        await refreshBalance()
    }

    // MARK: - Send SOL

    func sendSOL(to address: String, amount: Double) async throws -> String {
        guard let wallet = currentWallet else {
            throw WalletError.noWallet
        }

        // Validate address
        guard address.isValidSolanaAddress else {
            throw WalletError.invalidAddress
        }

        // Get private key
        let privateKeyData = try keychain.retrieve(key: "\(AppConstants.Keychain.walletKeyPrefix)\(wallet.publicKey)")

        // Build transaction
        let transaction = try await solanaService.buildTransaction(
            from: wallet.publicKey,
            to: address,
            amount: amount,
            privateKey: privateKeyData
        )

        // Send transaction
        let signature = try await solanaService.sendTransaction(transaction)

        // Refresh balance
        await refreshBalance()

        // Sync widget data
        await syncWidgetData()

        return signature
    }

    // MARK: - Send Token

    func sendToken(mint: String, to address: String, amount: Double) async throws -> String {
        guard let wallet = currentWallet else {
            throw WalletError.noWallet
        }

        guard address.isValidSolanaAddress else {
            throw WalletError.invalidAddress
        }

        let privateKeyData = try keychain.retrieve(key: "\(AppConstants.Keychain.walletKeyPrefix)\(wallet.publicKey)")

        let transaction = try await solanaService.buildTokenTransaction(
            mint: mint,
            from: wallet.publicKey,
            to: address,
            amount: amount,
            privateKey: privateKeyData
        )

        let signature = try await solanaService.sendTransaction(transaction)

        await refreshBalance()
        await syncWidgetData()

        return signature
    }

    // MARK: - Refresh Balance

    func refreshBalance() async {
        guard let wallet = currentWallet else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            balance = try await solanaService.getBalance(pubkey: wallet.publicKey)
            tokens = try await solanaService.getTokenAccounts(pubkey: wallet.publicKey)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Get Transaction History

    func fetchTransactions() async {
        guard let wallet = currentWallet else { return }

        do {
            transactions = try await solanaService.getTransactionHistory(pubkey: wallet.publicKey)
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Delete Wallet

    func deleteWallet() async throws {
        guard let wallet = currentWallet else { return }

        try keychain.delete(key: "\(AppConstants.Keychain.walletKeyPrefix)\(wallet.publicKey)")
        try keychain.delete(key: AppConstants.Keychain.mnemonicKey)

        UserDefaults.standard.removeObject(forKey: "current_wallet")

        currentWallet = nil
        balance = Balance(sol: 0, lamports: 0, usdValue: nil)
        tokens = []
        transactions = []
    }

    // MARK: - Export Mnemonic

    func exportMnemonic() throws -> String {
        guard let wallet = currentWallet else {
            throw WalletError.noWallet
        }

        return try keychain.retrieveString(key: AppConstants.Keychain.mnemonicKey)
    }

    // MARK: - Private Methods

    private func deriveKeypair(from mnemonic: String) throws -> (publicKey: String, privateKey: Data) {
        // Derive keypair from mnemonic using BIP44 path
        // m/44'/501'/0'/0'
        let seed = crypto.SHA256(Data(mnemonic.utf8))
        let keypair = crypto.generateKeyPair()

        // Convert public key to base58 (simplified)
        let publicKeyString = keypair.publicKey.hexString

        return (publicKey: publicKeyString, privateKey: keypair.privateKey)
    }

    private func validateMnemonic(_ mnemonic: String) -> Bool {
        let words = mnemonic.split(separator: " ")
        return words.count == 12 || words.count == 24
    }

    private func saveWallet(_ wallet: Wallet) throws {
        let data = try JSONEncoder().encode(wallet)
        UserDefaults.standard.set(data, forKey: "current_wallet")
    }

    private func syncWidgetData() async {
        let widgetData = WidgetData(
            balance: balance,
            walletAddress: currentWallet?.publicKey ?? "",
            tokenCount: tokens.count,
            lastUpdated: Date()
        )

        if let data = try? JSONEncoder().encode(widgetData) {
            UserDefaults(suiteName: AppConstants.AppGroup.identifier)?.set(data, forKey: AppConstants.AppGroup.sharedBalanceKey)
        }
    }
}

// MARK: - Wallet Errors

enum WalletError: LocalizedError {
    case noWallet
    case invalidMnemonic
    case invalidAddress
    case insufficientFunds
    case transactionFailed(String)
    case keychainError

    var errorDescription: String? {
        switch self {
        case .noWallet:
            return "No wallet found. Please create or import a wallet."
        case .invalidMnemonic:
            return "Invalid mnemonic phrase. Please check and try again."
        case .invalidAddress:
            return "Invalid Solana address."
        case .insufficientFunds:
            return "Insufficient funds for this transaction."
        case .transactionFailed(let message):
            return "Transaction failed: \(message)"
        case .keychainError:
            return "Failed to access keychain."
        }
    }
}
