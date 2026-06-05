import SwiftUI
import WidgetKit

// MARK: - Main App

@main
struct SolanaWalletApp: App {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared

    @State private var deepLinkAction: DeepLinkAction?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(walletManager)
                .environmentObject(biometricAuth)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .task {
                    await walletManager.loadWallet()
                }
        }
    }

    // MARK: - Deep Link Handler

    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        switch components.path {
        case "/send":
            var amount: Double = 0.1
            var recipient = ""

            if let queryItems = components.queryItems {
                if let amountStr = queryItems.first(where: { $0.name == "amount" })?.value,
                   let amountVal = Double(amountStr) {
                    amount = amountVal
                }
                if let recipientStr = queryItems.first(where: { $0.name == "to" })?.value {
                    recipient = recipientStr
                }
            }

            deepLinkAction = .send(amount: amount, recipient: recipient)

        case "/receive":
            deepLinkAction = .receive

        case "/swap":
            deepLinkAction = .swap

        case "/widget/send":
            if let queryItems = components.queryItems,
               let amountStr = queryItems.first(where: { $0.name == "amount" })?.value,
               let amount = Double(amountStr) {
                deepLinkAction = .send(amount: amount, recipient: "")
            }

        default:
            break
        }
    }
}

// MARK: - Deep Link Action

enum DeepLinkAction {
    case send(amount: Double, recipient: String)
    case receive
    case swap
}
