import Foundation

// MARK: - Token Manager

final class TokenManager {
    static let shared = TokenManager()

    private let solanaService = SolanaService.shared

    // Known token metadata cache
    private var tokenMetadataCache: [String: TokenMetadata] = []

    private init() {
        loadCache()
    }

    // MARK: - Get Token Info

    func getTokenInfo(mint: String) async throws -> TokenMetadata {
        // Check cache first
        if let cached = tokenMetadataCache.first(where: { $0.mint == mint }) {
            return cached
        }

        // Fetch from on-chain or API
        let metadata = try await fetchTokenMetadata(mint: mint)

        // Cache it
        tokenMetadataCache.append(metadata)
        saveCache()

        return metadata
    }

    // MARK: - Get All Token Balances

    func getAllTokenBalances(walletAddress: String) async throws -> [Token] {
        return try await solanaService.getTokenAccounts(pubkey: walletAddress)
    }

    // MARK: - Get Token Price

    func getTokenPrice(mint: String) async throws -> Double {
        // TODO: Integrate with CoinGecko or Jupiter Price API
        // For now, return 0
        return 0.0
    }

    // MARK: - Get SOL Price

    func getSOLPrice() async throws -> Double {
        // TODO: Fetch from CoinGecko API
        return 0.0
    }

    // MARK: - Popular Tokens

    func getPopularTokens() -> [TokenMetadata] {
        return [
            TokenMetadata(
                mint: "So11111111111111111111111111111111111111112",
                name: "Solana",
                symbol: "SOL",
                decimals: 9,
                logoURL: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png"
            ),
            TokenMetadata(
                mint: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
                name: "USD Coin",
                symbol: "USDC",
                decimals: 6,
                logoURL: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v/logo.png"
            ),
            TokenMetadata(
                mint: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
                name: "Tether USD",
                symbol: "USDT",
                decimals: 6,
                logoURL: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.png"
            ),
            TokenMetadata(
                mint: "mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So",
                name: "Marinade staked SOL",
                symbol: "mSOL",
                decimals: 9,
                logoURL: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So/logo.png"
            ),
            TokenMetadata(
                mint: "7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj",
                name: "Lido staked SOL",
                symbol: "stSOL",
                decimals: 9,
                logoURL: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj/logo.png"
            )
        ]
    }

    // MARK: - Private Methods

    private func fetchTokenMetadata(mint: String) async throws -> TokenMetadata {
        // TODO: Implement actual metadata fetching
        // Options:
        // 1. Solana Token Registry
        // 2. Metaplex Metadata
        // 3. Custom API

        return TokenMetadata(
            mint: mint,
            name: "Unknown Token",
            symbol: "???",
            decimals: 9,
            logoURL: nil
        )
    }

    private func loadCache() {
        if let data = UserDefaults.standard.data(forKey: "token_metadata_cache"),
           let cache = try? JSONDecoder().decode([TokenMetadata].self, from: data) {
            tokenMetadataCache = cache
        }
    }

    private func saveCache() {
        if let data = try? JSONEncoder().encode(tokenMetadataCache) {
            UserDefaults.standard.set(data, forKey: "token_metadata_cache")
        }
    }
}

// MARK: - Token Metadata Model

struct TokenMetadata: Codable, Identifiable {
    let mint: String
    let name: String
    let symbol: String
    let decimals: Int
    let logoURL: String?

    var id: String { mint }
}
