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
        VStack(spacing: 32) {
            Spacer()

            // Logo
            Image(systemName: "wave.3.right.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            // Title
            VStack(spacing: 8) {
                Text("Solana Wallet")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your gateway to the Solana ecosystem")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: 16) {
                Button(action: { showCreateWallet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create New Wallet")
                    }
                    .primaryButtonStyle()
                }

                Button(action: { showImportWallet = true }) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Import Existing Wallet")
                    }
                    .secondaryButtonStyle()
                }
            }
            .padding(.horizontal, 32)

            Spacer()
        }
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
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Create New Wallet")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Generate a new wallet with a fresh recovery phrase")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // Form
                Form {
                    Section("Wallet Name") {
                        TextField("My Wallet", text: $walletName)
                    }

                    Section {
                        Button(action: createWallet) {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Wallet")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.blue)
                        .foregroundColor(.white)
                        .disabled(walletName.isEmpty || isLoading)
                    }
                }
            }
            .navigationTitle("Create Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
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
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Import Existing Wallet")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Restore your wallet using your recovery phrase")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // Form
                Form {
                    Section("Wallet Name") {
                        TextField("My Wallet", text: $walletName)
                    }

                    Section("Recovery Phrase") {
                        TextEditor(text: $mnemonic)
                            .frame(minHeight: 100)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        Text("Enter your 12 or 24 word recovery phrase")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Section {
                        Button(action: importWallet) {
                            HStack {
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Import Wallet")
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                            }
                        }
                        .listRowBackground(Color.blue)
                        .foregroundColor(.white)
                        .disabled(walletName.isEmpty || mnemonic.isEmpty || isLoading)
                    }
                }
            }
            .navigationTitle("Import Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
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
