import WidgetKit
import SwiftUI

// MARK: - Widget Provider

struct SolanaWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SolanaEntry {
        SolanaEntry(
            date: Date(),
            balance: Balance(sol: 10.5, lamports: 10_500_000_000, usdValue: 1234.56),
            walletAddress: "7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SolanaEntry) -> Void) {
        let entry = SolanaEntry(
            date: Date(),
            balance: Balance(sol: 0, lamports: 0, usdValue: nil),
            walletAddress: ""
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SolanaEntry>) -> Void) {
        Task {
            let entry = await fetchBalance()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func fetchBalance() async -> SolanaEntry {
        // Read from shared UserDefaults (App Groups)
        guard let sharedDefaults = UserDefaults(suiteName: AppConstants.AppGroup.identifier),
              let data = sharedDefaults.data(forKey: AppConstants.AppGroup.sharedBalanceKey),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return SolanaEntry(
                date: Date(),
                balance: Balance(sol: 0, lamports: 0, usdValue: nil),
                walletAddress: ""
            )
        }

        return SolanaEntry(
            date: widgetData.lastUpdated,
            balance: widgetData.balance,
            walletAddress: widgetData.walletAddress
        )
    }
}

// MARK: - Widget Entry

struct SolanaEntry: TimelineEntry {
    let date: Date
    let balance: Balance
    let walletAddress: String
}
