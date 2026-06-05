import Foundation

// MARK: - Transaction Builder

final class TransactionBuilder {
    static let shared = TransactionBuilder()

    private init() {}

    // MARK: - Build System Transfer

    func buildSystemTransfer(
        from: String,
        to: String,
        lamports: UInt64,
        recentBlockhash: String
    ) throws -> TransactionMessage {
        // Create transfer instruction
        let instruction = TransactionInstruction(
            programId: "11111111111111111111111111111111",
            accounts: [from, to],
            data: encodeTransferData(lamports: lamports)
        )

        return TransactionMessage(
            header: MessageHeader(
                numRequiredSignatures: 1,
                numReadonlySignedAccounts: 0,
                numReadonlyUnsignedAccounts: 1
            ),
            recentBlockhash: recentBlockhash,
            accountKeys: [from, to, "11111111111111111111111111111111"],
            instructions: [instruction]
        )
    }

    // MARK: - Build Token Transfer

    func buildTokenTransfer(
        mint: String,
        from: String,
        to: String,
        amount: UInt64,
        decimals: Int,
        recentBlockhash: String
    ) throws -> TransactionMessage {
        // Find or create token accounts
        let fromATA = try findAssociatedTokenAddress(wallet: from, mint: mint)
        let toATA = try findAssociatedTokenAddress(wallet: to, mint: mint)

        let instruction = TransactionInstruction(
            programId: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            accounts: [fromATA, toATA, from],
            data: encodeTokenTransferData(amount: amount, decimals: decimals)
        )

        return TransactionMessage(
            header: MessageHeader(
                numRequiredSignatures: 1,
                numReadonlySignedAccounts: 0,
                numReadonlyUnsignedAccounts: 1
            ),
            recentBlockhash: recentBlockhash,
            accountKeys: [from, to, fromATA, toATA, mint, "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"],
            instructions: [instruction]
        )
    }

    // MARK: - Build Memo Transaction

    func buildMemoTransaction(
        from: String,
        memo: String,
        recentBlockhash: String
    ) throws -> TransactionMessage {
        let instruction = TransactionInstruction(
            programId: "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr",
            accounts: [from],
            data: memo.data(using: .utf8)?.base64EncodedString() ?? ""
        )

        return TransactionMessage(
            header: MessageHeader(
                numRequiredSignatures: 1,
                numReadonlySignedAccounts: 0,
                numReadonlyUnsignedAccounts: 0
            ),
            recentBlockhash: recentBlockhash,
            accountKeys: [from, "MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr"],
            instructions: [instruction]
        )
    }

    // MARK: - Serialize Transaction

    func serialize(message: TransactionMessage) throws -> Data {
        var data = Data()

        // Header
        data.append(contentsOf: [
            UInt8(message.header.numRequiredSignatures),
            UInt8(message.header.numReadonlySignedAccounts),
            UInt8(message.header.numReadonlyUnsignedAccounts)
        ])

        // Account keys (base58 encoded)
        for key in message.accountKeys {
            let keyData = key.data(using: .utf8) ?? Data()
            data.append(UInt8(keyData.count))
            data.append(keyData)
        }

        // Recent blockhash
        let blockhashData = message.recentBlockhash.data(using: .utf8) ?? Data()
        data.append(UInt8(blockhashData.count))
        data.append(blockhashData)

        // Instructions
        data.append(UInt8(message.instructions.count))
        for instruction in message.instructions {
            data.append(UInt8(0)) // program ID index
            data.append(UInt8(instruction.accounts.count))
            for account in instruction.accounts {
                data.append(UInt8(0)) // account index
            }
            let instructionData = Data(base64Encoded: instruction.data) ?? Data()
            data.append(UInt16(instructionData.count))
            data.append(instructionData)
        }

        return data
    }

    // MARK: - Private Helpers

    private func encodeTransferData(lamports: UInt64) -> String {
        // System Program transfer instruction
        // Format: 4 bytes (instruction type) + 8 bytes (lamports)
        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: UInt32(2).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: lamports.littleEndian) { Array($0) })
        return data.base64EncodedString()
    }

    private func encodeTokenTransferData(amount: UInt64, decimals: Int) -> String {
        // SPL Token transfer instruction
        // Format: 4 bytes (instruction type) + 8 bytes (amount)
        var data = Data()
        data.append(contentsOf: withUnsafeBytes(of: UInt32(3).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: amount.littleEndian) { Array($0) })
        return data.base64EncodedString()
    }

    private func findAssociatedTokenAddress(wallet: String, mint: String) throws -> String {
        // Derive associated token address
        // In production, use proper address derivation
        return "\(wallet)-\(mint)-ATA"
    }
}

// MARK: - Transaction Message Models

struct TransactionMessage {
    let header: MessageHeader
    let recentBlockhash: String
    let accountKeys: [String]
    let instructions: [TransactionInstruction]
}

struct MessageHeader {
    let numRequiredSignatures: Int
    let numReadonlySignedAccounts: Int
    let numReadonlyUnsignedAccounts: Int
}

struct TransactionInstruction {
    let programId: String
    let accounts: [String]
    let data: String
}
