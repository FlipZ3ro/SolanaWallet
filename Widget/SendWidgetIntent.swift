import AppIntents
import WidgetKit

// MARK: - Send Intent

struct SendIntent: AppIntent {
    static var title: LocalizedStringResource = "Send SOL"
    static var description = IntentDescription("Send SOL from the widget")

    @Parameter(title: "Amount")
    var amount: String

    init() {
        self.amount = "0.1"
    }

    init(amount: String) {
        self.amount = amount
    }

    func perform() async throws -> some IntentResult {
        // Open the main app with send context
        // The widget cannot directly send SOL due to security restrictions
        // It needs to hand off to the main app for Face ID authentication

        let deepLink = "\(AppConstants.DeepLink.send)?amount=\(amount)"

        guard let url = URL(string: deepLink) else {
            return .result()
        }

        // Open the app via URL scheme
        await MainActor.run {
            UIApplication.shared.open(url)
        }

        return .result()
    }
}

// MARK: - Quick Send Intent

struct QuickSendIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Send"
    static var description = IntentDescription("Quickly send a preset amount of SOL")

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Recipient")
    var recipient: String

    init() {
        self.amount = 0.1
        self.recipient = ""
    }

    init(amount: Double, recipient: String) {
        self.amount = amount
        self.recipient = recipient
    }

    func perform() async throws -> some IntentResult {
        let deepLink = "\(AppConstants.DeepLink.send)?amount=\(amount)&to=\(recipient)"

        guard let url = URL(string: deepLink) else {
            return .result()
        }

        await MainActor.run {
            UIApplication.shared.open(url)
        }

        return .result()
    }
}

// MARK: - Refresh Balance Intent

struct RefreshBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Balance"
    static var description = IntentDescription("Refresh wallet balance")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Refresh balance from shared UserDefaults
        guard let sharedDefaults = UserDefaults(suiteName: AppConstants.AppGroup.identifier) else {
            return .result(dialog: "Failed to access shared data")
        }

        // Update the widget timeline
        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Balance refreshed!")
    }
}
