import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirmation = false
    @State private var showExportMnemonic = false
    @State private var exportedMnemonic = ""
    @State private var showCopiedAlert = false

    var body: some View {
        NavigationView {
            List {
                // Wallet Section
                walletSection

                // Security Section
                securitySection

                // Network Section
                networkSection

                // About Section
                aboutSection

                // Danger Zone
                dangerZone
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Wallet", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        try? await walletManager.deleteWallet()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this wallet? This action cannot be undone. Make sure you have backed up your recovery phrase.")
            }
            .sheet(isPresented: $showExportMnemonic) {
                exportMnemonicSheet
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    // MARK: - Wallet Section

    private var walletSection: some View {
        Section("Wallet") {
            if let wallet = walletManager.currentWallet {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(wallet.name)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Address")
                    Spacer()
                    Text(wallet.publicKey.truncatedAddress)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Button("Export Recovery Phrase") {
                    exportedMnemonic = (try? walletManager.exportMnemonic()) ?? ""
                    showExportMnemonic = true
                }
            } else {
                Text("No wallet found")
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Security Section

    private var securitySection: some View {
        Section("Security") {
            HStack {
                Text("Biometric Authentication")
                Spacer()
                if biometricAuth.isAvailable {
                    Text(biometricAuth.biometricType == .faceID ? "Face ID" : "Touch ID")
                        .foregroundColor(.secondary)
                } else {
                    Text("Not Available")
                        .foregroundColor(.red)
                }
            }

            Toggle("Require for Transactions", isOn: .constant(true))
        }
    }

    // MARK: - Network Section

    private var networkSection: some View {
        Section("Network") {
            HStack {
                Text("Network")
                Spacer()
                Text("Mainnet Beta")
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("RPC Endpoint")
                Spacer()
                Text("api.mainnet-beta.solana.com")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }

            Button("View on Explorer") {
                if let url = URL(string: AppConstants.Network.explorerMainnet) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }

            Button("Privacy Policy") {
                // TODO: Open privacy policy
            }

            Button("Terms of Service") {
                // TODO: Open terms of service
            }

            Button("Contact Support") {
                // TODO: Open support
            }
        }
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        Section {
            Button("Delete Wallet") {
                showDeleteConfirmation = true
            }
            .foregroundColor(.red)
        }
    }

    // MARK: - Export Mnemonic Sheet

    private var exportMnemonicSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Warning
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)

                    Text("Never share your recovery phrase with anyone!")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))

                // Mnemonic
                Text(exportedMnemonic)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))

                // Copy Button
                Button(action: {
                    UIPasteboard.general.string = exportedMnemonic
                    showCopiedAlert = true
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                        Text("Copy to Clipboard")
                    }
                    .primaryButtonStyle()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showExportMnemonic = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
