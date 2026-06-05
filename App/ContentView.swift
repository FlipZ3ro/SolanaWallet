import SwiftUI

// MARK: - Content View

struct ContentView: View {
    @StateObject private var walletManager = WalletManager.shared
    @StateObject private var biometricAuth = BiometricAuthManager.shared

    @State private var showCreateWallet = false
    @State private var showImportWallet = false

    var body: some View {
        Group {
            if walletManager.currentWallet != nil {
                MainTabView()
            } else {
                onboardingView
            }
        }
        .sheet(isPresented: $showCreateWallet) {
            CreateWalletView()
        }
        .sheet(isPresented: $showImportWallet) {
            ImportWalletView()
        }
    }

    // MARK: - Onboarding View

    private var onboardingView: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            // Ambient glow
            RadialGradient(
                colors: [Theme.accent.opacity(0.06), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo
                ZStack {
                    Circle()
                        .fill(Theme.accentDim)
                        .frame(width: 100, height: 100)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Theme.accent)
                }

                // Title
                VStack(spacing: 12) {
                    Text("SolanaWallet")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Theme.text)

                    Text("Your gateway to the Solana ecosystem")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: { showCreateWallet = true }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Create New Wallet")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Theme.bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button(action: { showImportWallet = true }) {
                        HStack {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Import Existing Wallet")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Theme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Wallet", systemImage: "wallet.pass.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Theme.accent)
    }
}

// MARK: - Create Wallet View

struct CreateWalletView: View {
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var walletName = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentDim)
                                .frame(width: 72, height: 72)

                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }

                        Text("Create New Wallet")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Theme.text)

                        Text("Generate a new wallet with a fresh recovery phrase")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Form
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wallet Name")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextField("My Wallet", text: $walletName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.text)
                                .padding(14)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                        }

                        Button(action: createWallet) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Theme.bg)
                                } else {
                                    Text("Create Wallet")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(Theme.bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(walletName.isEmpty || isLoading ? Theme.textTertiary : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(walletName.isEmpty || isLoading)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Create Wallet")
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func createWallet() {
        guard !walletName.isEmpty else { return }

        isLoading = true

        Task {
            do {
                _ = try await walletManager.createWallet(name: walletName)
                await MainActor.run {
                    isLoading = false
                    dismiss()
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

// MARK: - Import Wallet View

struct ImportWalletView: View {
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var walletName = ""
    @State private var mnemonic = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 28) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.accentDim)
                                .frame(width: 72, height: 72)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }

                        Text("Import Existing Wallet")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Theme.text)

                        Text("Restore your wallet using your recovery phrase")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Form
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Wallet Name")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextField("My Wallet", text: $walletName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.text)
                                .padding(14)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Recovery Phrase")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)

                            TextEditor(text: $mnemonic)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(Theme.text)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(14)
                                .background(Theme.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.cardBorder, lineWidth: 1)
                                )

                            Text("Enter your 12 or 24 word recovery phrase")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Theme.textTertiary)
                        }

                        Button(action: importWallet) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(Theme.bg)
                                } else {
                                    Text("Import Wallet")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(Theme.bg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(walletName.isEmpty || mnemonic.isEmpty || isLoading ? Theme.textTertiary : Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(walletName.isEmpty || mnemonic.isEmpty || isLoading)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Import Wallet")
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func importWallet() {
        guard !walletName.isEmpty, !mnemonic.isEmpty else { return }

        isLoading = true

        Task {
            do {
                _ = try await walletManager.importWallet(name: walletName, mnemonic: mnemonic.trimmingCharacters(in: .whitespacesAndNewlines))
                await MainActor.run {
                    isLoading = false
                    dismiss()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
