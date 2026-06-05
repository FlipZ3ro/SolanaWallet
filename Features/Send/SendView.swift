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
            Form {
                // Recipient Section
                Section("Recipient") {
                    TextField("Enter Solana address", text: $recipientAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)

                    Button("Paste from Clipboard") {
                        if let pasteboard = UIPasteboard.general.string {
                            recipientAddress = pasteboard
                        }
                    }
                    .foregroundColor(.blue)
                }

                // Amount Section
                Section("Amount") {
                    HStack {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)

                        Text("SOL")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Available: \(walletManager.balance.displaySOL) SOL")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Max") {
                            amount = String(walletManager.balance.sol)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }

                // Memo Section
                Section("Memo (Optional)") {
                    TextField("Add a memo", text: $memo)
                }

                // Send Button
                Section {
                    Button(action: { showConfirmation = true }) {
                        HStack {
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Send SOL")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(canSend ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .disabled(!canSend || isLoading)
                }
            }
            .navigationTitle("Send SOL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
            // Authenticate with Face ID
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

            // Send transaction
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
    }
}
