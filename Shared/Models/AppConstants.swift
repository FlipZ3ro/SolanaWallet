import Foundation

// MARK: - App Constants

enum AppConstants {
    // MARK: - Solana Network
    enum Network {
        static let mainnetRPC = "https://api.mainnet-beta.solana.com"
        static let devnetRPC = "https://api.devnet.solana.com"
        static let testnetRPC = "https://api.testnet.solana.com"

        static let explorerMainnet = "https://explorer.solana.com"
        static let explorerDevnet = "https://explorer.solana.com?cluster=devnet"
    }

    // MARK: - Keychain
    enum Keychain {
        static let service = "com.solanawallet.app"
        static let walletKeyPrefix = "wallet_"
        static let mnemonicKey = "mnemonic"
        static let pinKey = "pin"
    }

    // MARK: - App Group
    enum AppGroup {
        static let identifier = "group.com.solanawallet.app"
        static let sharedDefaults = "shared_defaults"
        static let sharedBalanceKey = "shared_balance"
        static let sharedAddressKey = "shared_address"
        static let sharedTokenKey = "shared_tokens"
    }

    // MARK: - Deep Links
    enum DeepLink {
        static let send = "solana-wallet://send"
        static let receive = "solana-wallet://receive"
        static let swap = "solana-wallet://swap"
        static let widgetSend = "solana-wallet://widget/send"
    }

    // MARK: - Fees
    enum Fees {
        static let lamportsPerSignature: UInt64 = 5000
        static let lamportsPerByte: UInt64 = 1
    }

    // MARK: - UI
    enum UI {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let iconSize: CGFloat = 24
    }

    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springDuration: Double = 0.5
    }
}
