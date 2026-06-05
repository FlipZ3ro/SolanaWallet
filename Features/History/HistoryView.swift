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
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await walletManager.fetchTransactions()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Filter Picker

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Button(action: { withAnimation(.snappy) { selectedFilter = filter } }) {
                        Text(filter.rawValue)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .semibold : .medium))
                            .foregroundColor(selectedFilter == filter ? Theme.bg : Theme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedFilter == filter ? Theme.accent : Theme.card
                            )
                            .clipShape(Capsule())
                            .overlay(
                                selectedFilter == filter ? nil :
                                    Capsule().stroke(Theme.cardBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
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
                                .background(Theme.cardBorder)
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
            ZStack {
                Circle()
                    .fill(Theme.card)
                    .frame(width: 72, height: 72)

                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 28))
                    .foregroundColor(Theme.textTertiary)
            }

            VStack(spacing: 6) {
                Text("No Transactions")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.text)

                Text("Your transaction history will appear here")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 80)
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
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(transactionTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.text)

                Text(transaction.addressDisplay)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transactionAmountDisplay)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(transaction.timestamp.timeAgoDisplay)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            // TODO: Show transaction details
        }
    }

    // MARK: - Helpers

    private var iconName: String {
        switch transaction.type {
        case .send:    return "arrow.up.right"
        case .receive: return "arrow.down.left"
        case .swap:    return "arrow.triangle.2.circlepath"
        case .unknown: return "questionmark.circle"
        }
    }

    private var iconColor: Color {
        switch transaction.type {
        case .send:    return Theme.send
        case .receive: return Theme.receive
        case .swap:    return Theme.swap
        case .unknown: return Theme.textSecondary
        }
    }

    private var transactionTitle: String {
        switch transaction.type {
        case .send:    return "Sent SOL"
        case .receive: return "Received SOL"
        case .swap:    return "Swapped Token"
        case .unknown: return "Transaction"
        }
    }

    private var transactionAmountDisplay: String {
        let prefix = transaction.type == .send ? "-" : "+"
        return "\(prefix)\(String(format: "%.4f", transaction.amount)) SOL"
    }

    private var addressDisplay: String {
        switch transaction.type {
        case .send:    return transaction.to.truncatedAddress
        case .receive: return transaction.from.truncatedAddress
        default:       return ""
        }
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .preferredColorScheme(.dark)
    }
}
