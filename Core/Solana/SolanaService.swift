import Foundation

// MARK: - Solana Service

final class SolanaService {
    static let shared = SolanaService()

    private let session = URLSession.shared
    private let rpcURL = AppConstants.Network.mainnetRPC
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - RPC Request

    private func makeRequest<T: Codable>(
        method: String,
        params: [Any] = []
    ) async throws -> RPCResponse<T> {
        var requestBody: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": method,
            "params": params
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: URL(string: rpcURL)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SolanaError.networkError
        }

        return try decoder.decode(RPCResponse<T>.self, from: data)
    }

    // MARK: - Get Balance

    func getBalance(pubkey: String) async throws -> Balance {
        let response: RPCResponse<BalanceResponse> = try await makeRequest(
            method: "getBalance",
            params: [pubkey]
        )

        guard let result = response.result else {
            throw SolanaError.invalidResponse
        }

        let sol = Double(result.value) / 1_000_000_000.0

        return Balance(
            sol: sol,
            lamports: result.value,
            usdValue: nil // TODO: Fetch USD price from CoinGecko
        )
    }

    // MARK: - Get Token Accounts

    func getTokenAccounts(pubkey: String) async throws -> [Token] {
        let response: RPCResponse<[TokenAccount]> = try await makeRequest(
            method: "getTokenAccountsByOwner",
            params: [
                pubkey,
                ["programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"],
                ["encoding": "jsonParsed"]
            ]
        )

        guard let accounts = response.result else {
            return []
        }

        return accounts.compactMap { account in
            guard let parsed = account.parsed else { return nil }
            let info = parsed.parsed.info
            let tokenAmount = info.tokenAmount

            return Token(
                id: account.pubkey,
                mint: info.mint,
                name: info.mint, // TODO: Fetch token metadata
                symbol: "SPL", // TODO: Fetch actual symbol
                decimals: tokenAmount.decimals,
                balance: tokenAmount.uiAmount,
                uiAmount: tokenAmount.uiAmount,
                logoURL: nil
            )
        }
    }

    // MARK: - Get Transaction History

    func getTransactionHistory(pubkey: String, limit: Int = 20) async throws -> [Transaction] {
        let response: RPCResponse<[TransactionSignature]> = try await makeRequest(
            method: "getSignaturesForAddress",
            params: [pubkey, ["limit": limit]]
        )

        guard let signatures = response.result else {
            return []
        }

        var transactions: [Transaction] = []

        for sig in signatures {
            let tx = Transaction(
                id: sig.signature,
                signature: sig.signature,
                type: .unknown, // TODO: Parse transaction type
                from: pubkey,
                to: "",
                amount: 0,
                tokenSymbol: "SOL",
                timestamp: Date(timeIntervalSince1970: Double(sig.blockTime ?? 0)),
                status: sig.err == nil ? .confirmed : .failed
            )
            transactions.append(tx)
        }

        return transactions
    }

    // MARK: - Get Recent Blockhash

    func getRecentBlockhash() async throws -> String {
        let response: RPCResponse<RecentBlockhash> = try await makeRequest(
            method: "getRecentBlockhash"
        )

        guard let result = response.result else {
            throw SolanaError.invalidResponse
        }

        return result.blockhash
    }

    // MARK: - Build Transaction

    func buildTransaction(
        from: String,
        to: String,
        amount: Double,
        privateKey: Data
    ) async throws -> String {
        let blockhash = try await getRecentBlockhash()
        let lamports = UInt64(amount * 1_000_000_000)

        // Build transaction message
        let message: [String: Any] = [
            "header": [
                "numRequiredSignatures": 1,
                "numReadonlySignedAccounts": 0,
                "numReadonlyUnsignedAccounts": 1
            ],
            "recentBlockhash": blockhash,
            "accountKeys": [from, to, "11111111111111111111111111111111"],
            "instructions": [
                [
                    "programId": "11111111111111111111111111111111",
                    "accounts": [from, to],
                    "data": encodeTransferData(lamports: lamports)
                ]
            ]
        ]

        // Sign transaction (simplified)
        let signature = CryptoHelper.shared.HMAC_SHA512(
            key: privateKey,
            data: try JSONSerialization.data(withJSONObject: message)
        )

        return signature.hexString
    }

    // MARK: - Build Token Transaction

    func buildTokenTransaction(
        mint: String,
        from: String,
        to: String,
        amount: Double,
        privateKey: Data
    ) async throws -> String {
        let blockhash = try await getRecentBlockhash()

        // Build token transfer instruction
        let message: [String: Any] = [
            "header": [
                "numRequiredSignatures": 1,
                "numReadonlySignedAccounts": 0,
                "numReadonlyUnsignedAccounts": 1
            ],
            "recentBlockhash": blockhash,
            "accountKeys": [from, to, mint, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"],
            "instructions": [
                [
                    "programId": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
                    "accounts": [from, to, mint],
                    "data": encodeTokenTransferData(amount: amount)
                ]
            ]
        ]

        let signature = CryptoHelper.shared.HMAC_SHA512(
            key: privateKey,
            data: try JSONSerialization.data(withJSONObject: message)
        )

        return signature.hexString
    }

    // MARK: - Send Transaction

    func sendTransaction(_ signedTx: String) async throws -> String {
        let response: RPCResponse<SendTransactionResponse> = try await makeRequest(
            method: "sendTransaction",
            params: [signedTx, ["encoding": "base64"]]
        )

        guard let result = response.result else {
            throw SolanaError.transactionFailed
        }

        return result.result
    }

    // MARK: - Helper Methods

    private func encodeTransferData(lamports: UInt64) -> String {
        // Simplified - in production use proper Base58 encoding
        return lamports.description
    }

    private func encodeTokenTransferData(amount: Double) -> String {
        // Simplified - in production use proper SPL Token instruction encoding
        return amount.description
    }
}

// MARK: - Solana Errors

enum SolanaError: LocalizedError {
    case networkError
    case invalidResponse
    case transactionFailed
    case invalidAddress

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidResponse:
            return "Invalid response from Solana network."
        case .transactionFailed:
            return "Transaction failed to send."
        case .invalidAddress:
            return "Invalid Solana address."
        }
    }
}
