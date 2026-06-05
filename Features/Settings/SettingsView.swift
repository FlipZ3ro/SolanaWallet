import SwiftUI
import UIKit

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
            ScrollView {
                VStack(spacing: 16) {
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
                .padding(16)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.accent)
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
        .preferredColorScheme(.dark)
    }

    // MARK: - Wallet Section

    private var walletSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Wallet")

            VStack(spacing: 0) {
                if let wallet = walletManager.currentWallet {
                    settingsRow(icon: "person.circle", label: "Name", value: wallet.name)
                    settingsDivider
                    settingsRow(icon: "wallet.pass", label: "Address", value: wallet.publicKey.truncatedAddress, valueFont: .system(size: 12, weight: .medium, design: .monospaced))

                    Button(action: {
                        exportedMnemonic = (try? walletManager.exportMnemonic()) ?? ""
                        showExportMnemonic = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "key.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.accent)
                                .frame(width: 28)

                            Text("Export Recovery Phrase")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Theme.accent)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.textTertiary)
                        }
                        .padding(14)
                    }
                } else {
                    Text("No wallet found")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .padding(14)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Security Section

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Security")

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "faceid")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.accent)
                        .frame(width: 28)

                    Text("Biometric Authentication")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.text)

                    Spacer()

                    if biometricAuth.isAvailable {
                        Text(biometricAuth.biometricType == .faceID ? "Face ID" : "Touch ID")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.accent)
                    } else {
                        Text("N/A")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.send)
                    }
                }
                .padding(14)

                settingsDivider

                Toggle(isOn: .constant(true)) {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.accent)
                            .frame(width: 28)

                        Text("Require for Transactions")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.text)
                    }
                }
                .tint(Theme.accent)
                .padding(14)
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Network Section

    private var networkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Network")

            VStack(spacing: 0) {
                settingsRow(icon: "globe", label: "Network", value: "Mainnet Beta")
                settingsDivider
                settingsRow(icon: "server.rack", label: "RPC Endpoint", value: "api.mainnet-beta.solana.com", valueFont: .system(size: 11, weight: .medium, design: .monospaced))
                settingsDivider

                Button(action: {
                    if let url = URL(string: AppConstants.Network.explorerMainnet) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.forward.square")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.accent)
                            .frame(width: 28)

                        Text("View on Explorer")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.accent)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.textTertiary)
                    }
                    .padding(14)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("About")

            VStack(spacing: 0) {
                settingsRow(icon: "info.circle", label: "Version", value: "1.0.0")
                settingsDivider

                Button(action: {}) {
                    settingsRow(icon: "doc.text", label: "Privacy Policy", value: nil, showChevron: true)
                }

                settingsDivider

                Button(action: {}) {
                    settingsRow(icon: "doc.plaintext", label: "Terms of Service", value: nil, showChevron: true)
                }

                settingsDivider

                Button(action: {}) {
                    settingsRow(icon: "envelope", label: "Contact Support", value: nil, showChevron: true)
                }
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Danger Zone")

            Button(action: { showDeleteConfirmation = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.send)
                        .frame(width: 28)

                    Text("Delete Wallet")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.send)

                    Spacer()
                }
                .padding(14)
                .background(Theme.send.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.send.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Export Mnemonic Sheet

    private var exportMnemonicSheet: some View {
        NavigationView {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Warning
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.swap)

                        Text("Never share your recovery phrase with anyone!")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.swap)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Theme.swap.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.swap.opacity(0.2), lineWidth: 1)
                    )

                    // Mnemonic
                    Text(exportedMnemonic)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(Theme.text)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )

                    // Copy Button
                    Button(action: {
                        UIPasteboard.general.string = exportedMnemonic
                        showCopiedAlert = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Copy to Clipboard")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Theme.bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Recovery Phrase")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showExportMnemonic = false
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Theme.textSecondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private func settingsRow(icon: String, label: String, value: String?, valueFont: Font = .system(size: 14, weight: .medium), showChevron: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.accent)
                .frame(width: 28)

            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Theme.text)

            Spacer()

            if let value {
                Text(value)
                    .font(valueFont)
                    .foregroundColor(Theme.textSecondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .padding(14)
    }

    private var settingsDivider: some View {
        Divider()
            .background(Theme.cardBorder)
            .padding(.leading, 52)
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
