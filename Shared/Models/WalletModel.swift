import Foundation

// MARK: - Wallet Model

struct Wallet: Identifiable, Codable {
    let id: UUID
    let name: String
    let publicKey: String
    let createdAt: Date
    var isActive: Bool

    init(name: String, publicKey: String) {
        self.id = UUID()
        self.name = name
        self.publicKey = publicKey
        self.createdAt = Date()
        self.isActive = true
    }
}

// MARK: - Token Model

struct Token: Identifiable, Codable {
    let id: String
    let mint: String
    let name: String
    let symbol: String
    let decimals: Int
    let balance: Double
    let uiAmount: Double
    let logoURL: String?

    var displayBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = min(decimals, 4)
        return formatter.string(from: NSNumber(value: balance)) ?? "0"
    }
}

// MARK: - Transaction Model

struct Transaction: Identifiable, Codable {
    let id: String
    let signature: String
    let type: TransactionType
    let from: String
    let to: String
    let amount: Double
    let tokenSymbol: String
    let timestamp: Date
    let status: TransactionStatus

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

enum TransactionType: String, Codable {
    case send
    case receive
    case swap
    case unknown
}

enum TransactionStatus: String, Codable {
    case confirmed
    case pending
    case failed
}

// MARK: - Balance Model

struct Balance: Codable {
    let sol: Double
    let lamports: UInt64
    let usdValue: Double?

    var displaySOL: String {
        String(format: "%.4f", sol)
    }

    var displayUSD: String {
        guard let usd = usdValue else { return "$0.00" }
        return String(format: "$%.2f", usd)
    }
}

// MARK: - Send Request Model

struct SendRequest: Codable {
    let toAddress: String
    let amount: Double
    let tokenMint: String?
    let memo: String?

    init(toAddress: String, amount: Double, tokenMint: String? = nil, memo: String? = nil) {
        self.toAddress = toAddress
        self.amount = amount
        self.tokenMint = tokenMint
        self.memo = memo
    }
}

// MARK: - Widget Data Model

struct WidgetData: Codable {
    let balance: Balance
    let walletAddress: String
    let tokenCount: Int
    let lastUpdated: Date

    static let empty = WidgetData(
        balance: Balance(sol: 0, lamports: 0, usdValue: 0),
        walletAddress: "",
        tokenCount: 0,
        lastUpdated: Date()
    )
}
