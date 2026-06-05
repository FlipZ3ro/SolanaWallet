import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared

    @State private var showingSendSheet = false
    @State private var showingReceiveSheet = false
    @State private var showingSettingsSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.UI.padding) {
                    // Balance Card
                    balanceCard

                    // Quick Actions
                    quickActions

                    // Token List
                    tokenList

                    // Recent Transactions
                    recentTransactions
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Wallet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gearshape")
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
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        VStack(spacing: 12) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline) {
                Text(walletManager.balance.displaySOL)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("SOL")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            Text(walletManager.balance.displayUSD)
                .font(.title3)
                .foregroundColor(.secondary)

            if let address = walletManager.currentWallet?.publicKey {
                Text(address.truncatedAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
        }
        .padding(AppConstants.UI.padding)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius))
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: AppConstants.UI.padding) {
            ActionButton(
                icon: "arrow.up.circle.fill",
                title: "Send",
                color: .red
            ) {
                showingSendSheet = true
            }

            ActionButton(
                icon: "arrow.down.circle.fill",
                title: "Receive",
                color: .green
            ) {
                showingReceiveSheet = true
            }

            ActionButton(
                icon: "arrow.triangle.2.circlepath",
                title: "Swap",
                color: .orange
            ) {
                // TODO: Show swap view
            }
        }
    }

    // MARK: - Token List

    private var tokenList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tokens")
                .font(.headline)

            if walletManager.tokens.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "wallet.pass")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No tokens found")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(walletManager.tokens) { token in
                    TokenRow(token: token)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Recent Transactions

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)

                Spacer()

                Button("See All") {
                    // TODO: Show all transactions
                }
                .font(.subheadline)
            }

            if walletManager.transactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(walletManager.transactions.prefix(5)) { tx in
                    TransactionRow(transaction: tx)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Token Row

struct TokenRow: View {
    let token: Token

    var body: some View {
        HStack {
            // Token Icon
            AsyncImage(url: URL(string: token.logoURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        Text(String(token.symbol.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(token.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(token.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(token.displayBalance)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("$0.00") // TODO: Calculate USD value
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            // Transaction Icon
            Image(systemName: transaction.type == .send ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .font(.title3)
                .foregroundColor(transaction.type == .send ? .red : .green)

            VStack(alignment: .leading) {
                Text(transaction.type == .send ? "Sent" : "Received")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.timestamp.timeAgoDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(transaction.type == .send ? "-" : "+")\(String(format: "%.4f", transaction.amount)) SOL")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(transaction.type == .send ? .red : .green)

                Text(transaction.status.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(transaction.status == .confirmed ? .green : .orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
