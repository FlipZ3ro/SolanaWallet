import WidgetKit
import SwiftUI

// MARK: - Widget Theme (shared with app)

private enum WTheme {
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let card = Color(red: 0.09, green: 0.09, blue: 0.12)
    static let accent = Color(red: 0.0, green: 0.96, blue: 0.52)      // #00F584
    static let accentDim = Color(red: 0.0, green: 0.96, blue: 0.52).opacity(0.12)
    static let text = Color.white
    static let textSec = Color.white.opacity(0.5)
    static let textTer = Color.white.opacity(0.25)
    static let send = Color(red: 1.0, green: 0.27, blue: 0.27)
    static let receive = Color(red: 0.0, green: 0.96, blue: 0.52)
    static let swap = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let border = Color.white.opacity(0.06)
}

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
        ZStack {
            // Background
            WTheme.bg

            // Subtle accent glow
            RadialGradient(
                colors: [WTheme.accent.opacity(0.06), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 120
            )

            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 6) {
                    Circle()
                        .fill(WTheme.accent)
                        .frame(width: 6, height: 6)

                    Text("SOL")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(WTheme.accent)

                    Spacer()

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8))
                        .foregroundColor(WTheme.textTer)
                }

                Spacer()

                // Balance
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.balance.displaySOL)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(WTheme.text)
                        .contentTransition(.numericText())

                    Text(entry.balance.displayUSD)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(WTheme.textSec)
                }
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        ZStack {
            // Background
            WTheme.bg

            // Accent glow
            RadialGradient(
                colors: [WTheme.accent.opacity(0.05), .clear],
                center: .leading,
                startRadius: 0,
                endRadius: 200
            )

            HStack(spacing: 16) {
                // Left: Balance
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(WTheme.accent)
                            .frame(width: 6, height: 6)

                        Text("Solana Wallet")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(WTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.balance.displaySOL)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(WTheme.text)

                        Text(entry.balance.displayUSD)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(WTheme.textSec)
                    }
                }

                Spacer()

                // Right: Actions
                VStack(spacing: 8) {
                    Button(intent: SendIntent(amount: "0.1")) {
                        widgetActionBtn(
                            icon: "arrow.up.right",
                            title: "Send",
                            color: WTheme.send
                        )
                    }

                    Link(destination: URL(string: AppConstants.DeepLink.receive)!) {
                        widgetActionBtn(
                            icon: "arrow.down.left",
                            title: "Receive",
                            color: WTheme.receive
                        )
                    }
                }
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Large Widget

    private var largeWidget: some View {
        ZStack {
            // Background
            WTheme.bg

            // Subtle accent glow top-right
            RadialGradient(
                colors: [WTheme.accent.opacity(0.05), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 180
            )

            // Subtle accent glow bottom-left
            RadialGradient(
                colors: [WTheme.accent.opacity(0.03), .clear],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 180
            )

            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 6) {
                    Circle()
                        .fill(WTheme.accent)
                        .frame(width: 6, height: 6)

                    Text("Solana Wallet")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(WTheme.accent)

                    Spacer()

                    if !entry.walletAddress.isEmpty {
                        Text(entry.walletAddress.truncatedAddress)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(WTheme.textTer)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(WTheme.border)
                            .clipShape(Capsule())
                    }
                }

                // Balance
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Balance")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(WTheme.textSec)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(entry.balance.displaySOL)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(WTheme.text)

                        Text("SOL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(WTheme.textSec)
                    }

                    Text(entry.balance.displayUSD)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(WTheme.textSec)
                }

                // Divider
                Rectangle()
                    .fill(WTheme.border)
                    .frame(height: 1)

                // Quick Actions
                HStack(spacing: 10) {
                    Button(intent: SendIntent(amount: "0.1")) {
                        widgetLargeActionBtn(
                            icon: "arrow.up.right",
                            title: "Send",
                            color: WTheme.send
                        )
                    }

                    Link(destination: URL(string: AppConstants.DeepLink.receive)!) {
                        widgetLargeActionBtn(
                            icon: "arrow.down.left",
                            title: "Receive",
                            color: WTheme.receive
                        )
                    }

                    Link(destination: URL(string: AppConstants.DeepLink.swap)!) {
                        widgetLargeActionBtn(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Swap",
                            color: WTheme.swap
                        )
                    }
                }

                // Last Updated
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 8))
                    Text("Updated \(entry.date, style: .relative) ago")
                }
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(WTheme.textTer)
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Helpers

    private func widgetActionBtn(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(title)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [color.opacity(0.7), color.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
    }

    private func widgetLargeActionBtn(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(WTheme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(WTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(WTheme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Widget Bundle

@main
struct SolanaWidgetBundle: WidgetBundle {
    var body: some Widget {
        BalanceWidget()
    }
}
