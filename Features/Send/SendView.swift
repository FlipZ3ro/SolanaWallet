import SwiftUI
import UIKit

// MARK: - Send View

struct SendView: View {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var recipientAddress = ""
    @State private var amount = ""
    @State private var memo = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showConfirmation = false
    @State private var showSuccess = false
    @State private var transactionSignature = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Recipient
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recipient")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextField("Enter Solana address", text: $recipientAddress)
                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.text)
                                .padding(14)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )

                            Button(action: {
                                if let pasteboard = UIPasteboard.general.string {
                                    recipientAddress = pasteboard
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "doc.on.clipboard")
                                        .font(.system(size: 12))
                                    Text("Paste from Clipboard")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(Theme.accent)
                            }
                        }

                        // Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            HStack {
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.text)
                                    .keyboardType(.decimalPad)

                                Text("SOL")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .padding(14)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.cardBorder, lineWidth: 1)
                            )

                            HStack {
                                Text("Available: \(walletManager.balance.displaySOL) SOL")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Theme.textSecondary)

                                Spacer()

                                Button("Max") {
                                    amount = String(walletManager.balance.sol)
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.accent)
                            }
                        }

                        // Memo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Memo (Optional)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextField("Add a memo", text: $memo)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Theme.text)
                                .padding(14)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                        }

                        // Send Button
                        Button(action: { showConfirmation = true }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Theme.bg)
                                } else {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Send SOL")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(Theme.bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSend ? Theme.send : Theme.textTertiary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(!canSend || isLoading)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Send SOL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .alert("Confirm Transaction", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm") {
                    performSend()
                }
            } message: {
                Text("Send \(amount) SOL to \(recipientAddress.truncatedAddress)?")
            }
            .alert("Transaction Sent!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                VStack {
                    Text("Your transaction has been submitted.")
                    Text("Signature: \(transactionSignature.truncatedAddress)")
                        .font(.caption)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Computed Properties

    private var canSend: Bool {
        !recipientAddress.isEmpty &&
        recipientAddress.isValidSolanaAddress &&
        (Double(amount) ?? 0) > 0 &&
        (Double(amount) ?? 0) <= walletManager.balance.sol
    }

    // MARK: - Perform Send

    private func performSend() {
        guard canSend else { return }

        isLoading = true

        Task {
            let authenticated = await biometricAuth.authenticateForTransaction(
                amount: amount,
                recipient: recipientAddress
            )

            guard authenticated else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Authentication failed"
                    showError = true
                }
                return
            }

            do {
                let signature = try await walletManager.sendSOL(
                    to: recipientAddress,
                    amount: Double(amount) ?? 0
                )

                await MainActor.run {
                    isLoading = false
                    transactionSignature = signature
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Preview

struct SendView_Previews: PreviewProvider {
    static var previews: some View {
        SendView()
            .preferredColorScheme(.dark)
    }
}
