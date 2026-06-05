import Foundation

// MARK: - Solana RPC Response Models

struct RPCResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int
    let result: T?
    let error: RPCError?
}

struct RPCError: Codable {
    let code: Int
    let message: String
}

// MARK: - Balance Response

struct BalanceResponse: Codable {
    let context: Context
    let value: UInt64

    struct Context: Codable {
        let apiVersion: String
        let slot: Int
    }
}

// MARK: - Account Info

struct AccountInfo: Codable {
    let data: [String]
    let executable: Bool
    let lamports: UInt64
    let owner: String
    let rentEpoch: Int
}

// MARK: - Token Account

struct TokenAccount: Codable {
    let pubkey: String
    let account: AccountInfo

    var parsed: ParsedTokenAccount? {
        guard let data = account.data.first,
              let jsonData = data.data(using: .utf8),
              let parsed = try? JSONDecoder().decode(ParsedTokenAccount.self, from: jsonData) else {
            return nil
        }
        return parsed
    }
}

struct ParsedTokenAccount: Codable {
    let parsed: ParsedInfo
    let program: String
    let space: Int

    struct ParsedInfo: Codable {
        let info: TokenInfo
        let type: String

        struct TokenInfo: Codable {
            let isNative: Bool
            let mint: String
            let owner: String
            let tokenAmount: TokenAmount

            struct TokenAmount: Codable {
                let amount: String
                let decimals: Int
                let uiAmount: Double
                let uiAmountString: String
            }
        }
    }
}

// MARK: - Transaction History

struct TransactionSignature: Codable {
    let blockTime: Int64?
    let confirmationStatus: String?
    let err: TransactionError?
    let memo: [String]?
    let signature: String
    let slot: Int
}

struct TransactionError: Codable {
    let InstructionError: [InstructionError]?
}

struct InstructionError: Codable {
    let Custom: Int?
}

// MARK: - Recent Blockhash

struct RecentBlockhash: Codable {
    let blockhash: String
    let lastValidBlockHeight: Int
}

// MARK: - Send Transaction Response

struct SendTransactionResponse: Codable {
    let result: String
}
