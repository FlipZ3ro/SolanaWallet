import SwiftUI

// MARK: - Theme

enum Theme {
    static let bg = Color(red: 0.04, green: 0.04, blue: 0.06)         // #0a0a0f
    static let card = Color(red: 0.08, green: 0.08, blue: 0.11)       // #141416
    static let cardBorder = Color.white.opacity(0.06)
    static let accent = Color(red: 0.0, green: 0.96, blue: 0.52)      // #00F584
    static let accentDim = Color(red: 0.0, green: 0.96, blue: 0.52).opacity(0.15)
    static let text = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let textTertiary = Color.white.opacity(0.3)
    static let send = Color(red: 1.0, green: 0.27, blue: 0.27)        // #FF4545
    static let receive = Color(red: 0.0, green: 0.96, blue: 0.52)     // #00F584
    static let swap = Color(red: 1.0, green: 0.6, blue: 0.0)          // #FF9900
    static let cardGradientStart = Color(red: 0.0, green: 0.15, blue: 0.12)
    static let cardGradientEnd = Color(red: 0.08, green: 0.0, blue: 0.15)
}

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared

    @State private var showingSendSheet = false
    @State private var showingReceiveSheet = false
    @State private var showingSettingsSheet = false
    @State private var balanceHidden = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Balance Card
                    balanceCard

                    // Quick Actions
                    quickActions

                    // Token List
                    tokenList

                    // Recent Transactions
                    recentTransactions
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(Theme.card)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Theme.cardBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .sheet(isPresented: $showingSendSheet) {
                SendView()
            }
            .sheet(isPresented: $showingReceiveSheet) {
                ReceiveView()
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
            .task {
                await walletManager.loadWallet()
            }
            .refreshable {
                await walletManager.refreshBalance()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 20) {
            // Network indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 6, height: 6)
                Text("Mainnet")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.accent)
                Spacer()
            }

            // Balance
            VStack(spacing: 4) {
                Text("Total Balance")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(balanceHidden ? "•••••" : walletManager.balance.displaySOL)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.text)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: walletManager.balance.sol)

                    Text("SOL")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                }

                Text(balanceHidden ? "•••••" : walletManager.balance.displayUSD)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            // Address pill
            if let address = walletManager.currentWallet?.publicKey {
                Button(action: {
                    UIPasteboard.general.string = address
                }) {
                    HStack(spacing: 6) {
                        Text(address.truncatedAddress)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.textSecondary)

                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.accent)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Theme.cardGradientStart, Theme.cardGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Subtle glow
                RadialGradient(
                    colors: [Theme.accent.opacity(0.08), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
        .shadow(color: Theme.accent.opacity(0.1), radius: 20, y: 10)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 12) {
            ModernActionButton(
                icon: "arrow.up.right",
                title: "Send",
                color: Theme.send,
                gradient: [Theme.send.opacity(0.8), Theme.send.opacity(0.4)]
            ) {
                showingSendSheet = true
            }

            ModernActionButton(
                icon: "arrow.down.left",
                title: "Receive",
                color: Theme.receive,
                gradient: [Theme.receive.opacity(0.8), Theme.receive.opacity(0.4)]
            ) {
                showingReceiveSheet = true
            }

            ModernActionButton(
                icon: "arrow.triangle.2.circlepath",
                title: "Swap",
                color: Theme.swap,
                gradient: [Theme.swap.opacity(0.8), Theme.swap.opacity(0.4)]
            ) {
                // TODO: Show swap view
            }
        }
    }

    // MARK: - Token List

    private var tokenList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tokens")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.text)

                Spacer()

                Text("\(walletManager.tokens.count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.card)
                    .clipShape(Capsule())
            }

            if walletManager.tokens.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.textTertiary)

                    Text("No tokens found")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(walletManager.tokens) { token in
                    TokenRow(token: token)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Recent Transactions

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.text)

                Spacer()

                Button("See All") {
                    // TODO: Show all transactions
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.accent)
            }

            if walletManager.transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.textTertiary)

                    Text("No transactions yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(walletManager.transactions.prefix(5)) { tx in
                    TransactionRow(transaction: tx)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Modern Action Button

struct ModernActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let gradient: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Token Row

struct TokenRow: View {
    let token: Token

    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            AsyncImage(url: URL(string: token.logoURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle()
                    .fill(Theme.accentDim)
                    .overlay(
                        Text(String(token.symbol.prefix(1)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.accent)
                    )
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(token.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.text)

                Text(token.symbol)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(token.displayBalance)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.text)

                Text("$0.00")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Transaction Icon
            ZStack {
                Circle()
                    .fill(transaction.type == .send ? Theme.send.opacity(0.15) : Theme.receive.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: transaction.type == .send ? "arrow.up.right" : "arrow.down.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(transaction.type == .send ? Theme.send : Theme.receive)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.type == .send ? "Sent" : "Received")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.text)

                Text(transaction.timestamp.timeAgoDisplay)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type == .send ? "-" : "+")\(String(format: "%.4f", transaction.amount)) SOL")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(transaction.type == .send ? Theme.send : Theme.receive)

                Text(transaction.status.rawValue.capitalized)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(transaction.status == .confirmed ? Theme.accent : Theme.swap)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
