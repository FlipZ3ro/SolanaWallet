import SwiftUI

// MARK: - History View

struct HistoryView: View {
    @StateObject private var walletManager = WalletManager.shared

    @State private var selectedFilter: TransactionFilter = .all

    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case sent = "Sent"
        case received = "Received"
        case pending = "Pending"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Picker
                filterPicker

                // Transaction List
                transactionList
            }
            .navigationTitle("Transaction History")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await walletManager.fetchTransactions()
            }
        }
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Button(action: { selectedFilter = filter }) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? Color.blue : Color(.systemGray6)
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredTransactions.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredTransactions) { transaction in
                        TransactionDetailRow(transaction: transaction)

                        if transaction.id != filteredTransactions.last?.id {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No Transactions")
                .font(.headline)

            Text("Your transaction history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - Filtered Transactions

    private var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all:
            return walletManager.transactions
        case .sent:
            return walletManager.transactions.filter { $0.type == .send }
        case .received:
            return walletManager.transactions.filter { $0.type == .receive }
        case .pending:
            return walletManager.transactions.filter { $0.status == .pending }
        }
    }
}

// MARK: - Transaction Detail Row

struct TransactionDetailRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Transaction Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transactionTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.addressDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transactionAmountDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(iconColor)

                Text(transaction.timestamp.timeAgoDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: Show transaction details
        }
    }

    // MARK: - Helpers

    private var iconName: String {
        switch transaction.type {
        case .send:
            return "arrow.up.right"
        case .receive:
            return "arrow.down.left"
        case .swap:
            return "arrow.triangle.2.circlepath"
        case .unknown:
            return "questionmark.circle"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .send:
            return .red
        case .receive:
            return .green
        case .swap:
            return .orange
        case .unknown:
            return .gray
        }
    }

    private var transactionTitle: String {
        switch transaction.type {
        case .send:
            return "Sent SOL"
        case .receive:
            return "Received SOL"
        case .swap:
            return "Swapped Token"
        case .unknown:
            return "Transaction"
        }
    }

    private var transactionAmountDisplay: String {
        let prefix = transaction.type == .send ? "-" : "+"
        return "\(prefix)\(String(format: "%.4f", transaction.amount)) SOL"
    }

    private var addressDisplay: String {
        switch transaction.type {
        case .send:
            return transaction.to.truncatedAddress
        case .receive:
            return transaction.from.truncatedAddress
        default:
            return ""
        }
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
