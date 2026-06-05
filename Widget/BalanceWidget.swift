import WidgetKit
import SwiftUI

// MARK: - Balance Widget

struct BalanceWidget: Widget {
    let kind: String = "BalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SolanaWidgetProvider()) { entry in
            BalanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Solana Balance")
        .description("View your SOL balance at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget View

struct BalanceWidgetView: View {
    let entry: SolanaEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wave.3.right.circle.fill")
                    .foregroundColor(.green)

                Text("SOL")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.balance.displaySOL)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(entry.balance.displayUSD)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // Balance
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wave.3.right.circle.fill")
                        .foregroundColor(.green)

                    Text("Solana Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(entry.balance.displaySOL)
                    .font(.title)
                    .fontWeight(.bold)

                Text(entry.balance.displayUSD)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Quick Actions
            VStack(spacing: 12) {
                Button(intent: SendIntent(amount: "0.1")) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.red)
                        Text("Send")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }

                Link(destination: URL(string: AppConstants.DeepLink.receive)!) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                        Text("Receive")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
    }

    // MARK: - Large Widget

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "wave.3.right.circle.fill")
                    .foregroundColor(.green)

                Text("Solana Wallet")
                    .font(.headline)

                Spacer()

                if !entry.walletAddress.isEmpty {
                    Text(entry.walletAddress.truncatedAddress)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Balance
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Balance")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline) {
                    Text(entry.balance.displaySOL)
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("SOL")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Text(entry.balance.displayUSD)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Divider()
                .background(Color.white.opacity(0.3))

            // Quick Actions
            HStack(spacing: 12) {
                Button(intent: SendIntent(amount: "0.1")) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3)
                        Text("Send")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Link(destination: URL(string: AppConstants.DeepLink.receive)!) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3)
                        Text("Receive")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Link(destination: URL(string: AppConstants.DeepLink.swap)!) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                        Text("Swap")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Last Updated
            Text("Updated: \(entry.date, style: .relative) ago")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
    }
}

// MARK: - Widget Bundle

@main
struct SolanaWidgetBundle: WidgetBundle {
    var body: some Widget {
        BalanceWidget()
    }
}
