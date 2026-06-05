import AppIntents
import WidgetKit

// MARK: - Send Intent

struct SendIntent: AppIntent {
    static var title: LocalizedStringResource = "Send SOL"
    static var description = IntentDescription("Send SOL from the widget")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Amount")
    var amount: String

    init() {
        self.amount = "0.1"
    }

    init(amount: String) {
        self.amount = amount
    }

    func perform() async throws -> some IntentResult & OpensIntent {
        // The widget cannot directly send SOL due to security restrictions.
        // It hands off to the main app for Face ID authentication and signing.
        let deepLink = "\(AppConstants.DeepLink.send)?amount=\(amount)"

        guard let url = URL(string: deepLink) else {
            return .result()
        }

        return .result(opensIntent: OpenURLIntent(url))
    }
}

// MARK: - Quick Send Intent

struct QuickSendIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Send"
    static var description = IntentDescription("Quickly send a preset amount of SOL")
    static var openAppWhenRun: Bool = true

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

    func perform() async throws -> some IntentResult & OpensIntent {
        let deepLink = "\(AppConstants.DeepLink.send)?amount=\(amount)&to=\(recipient)"

        guard let url = URL(string: deepLink) else {
            return .result()
        }

        return .result(opensIntent: OpenURLIntent(url))
    }
}

// MARK: - Refresh Balance Intent

struct RefreshBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Balance"
    static var description = IntentDescription("Refresh wallet balance")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Refresh balance from shared UserDefaults
        guard UserDefaults(suiteName: AppConstants.AppGroup.identifier) != nil else {
            return .result(dialog: "Failed to access shared data")
        }

        // Update the widget timeline
        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Balance refreshed!")
    }
}
