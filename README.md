# 🚀 SolanaWallet

A secure Solana wallet iOS app with Widget extension for quick balance viewing and sending.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 🔐 **Secure Wallet** - Create or import wallet with recovery phrase
- 💰 **Balance Tracking** - View SOL and SPL token balances
- 📤 **Send SOL** - Send transactions with Face ID confirmation
- 📥 **Receive** - QR code and copy address
- 📊 **Transaction History** - View past transactions
- 📱 **Widget** - Quick balance view on home screen
- ⚡ **Quick Send** - Send SOL directly from widget
- 🔒 **Biometric Auth** - Face ID for transaction confirmation

## 🏗️ Architecture

```
SolanaWallet/
├── App/                    # Main app entry
├── Core/
│   ├── Wallet/             # Wallet management
│   ├── Solana/             # Solana RPC integration
│   └── Security/           # Face ID, Keychain, Secure Enclave
├── Features/               # UI Views
├── Widget/                 # WidgetKit extension
└── Shared/                 # Models and extensions
```

## 🔐 Security

| Feature | Implementation |
|---------|----------------|
| Private Key Storage | iOS Secure Enclave |
| Key Storage | iOS Keychain |
| Transaction Auth | Face ID / Touch ID |
| Widget Access | Read-only (cannot sign) |
| App Communication | App Groups + Keychain Sharing |

## 📱 Widget

The widget provides:
- **Small**: Quick balance view
- **Medium**: Balance + Quick actions (Send/Receive)
- **Large**: Full wallet overview with actions

**Note**: Widget cannot directly send SOL due to iOS security restrictions. It uses App Intents to hand off to the main app for Face ID authentication.

## 🛠️ Tech Stack

- **Language**: Swift 5.9+
- **UI**: SwiftUI
- **Widget**: WidgetKit + AppIntents
- **Crypto**: CryptoKit (native)
- **Key Storage**: Security framework (native)
- **Auth**: LocalAuthentication (Face ID)
- **Networking**: URLSession + JSON-RPC
- **State**: @Observable (iOS 17+)

> **Zero third-party dependencies** — everything uses native iOS frameworks.

## 🚀 Getting Started

### Prerequisites

- macOS 14+
- Xcode 15+
- iOS 17+ device or simulator
- XcodeGen (`brew install xcodegen`)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FlipZ3ro/SolanaWallet.git
   cd SolanaWallet
   ```

2. **Generate the Xcode project**
   ```bash
   ./setup.sh
   ```
   This runs XcodeGen to generate `SolanaWallet.xcodeproj` from the committed `project.yml`.

3. **Configure App Groups**
   - Select both app and widget targets
   - Signing & Capabilities → + Capability → App Groups
   - Enable: `group.com.solanawallet.app`

4. **Build and Run**
   - Select your device or simulator
   - Press ⌘R

## 📱 Testing on Device

### Option 1: Direct Run (Mac required)
1. Connect iPhone to Mac
2. Select device in Xcode
3. Press ⌘R

### Option 2: TestFlight
1. Archive app (Product → Archive)
2. Upload to App Store Connect
3. Invite testers via TestFlight

### Option 3: AltStore (No Mac required)
1. Install AltStore on iPhone
2. Build .ipa file
3. Sideload via AltStore

## 🔧 Configuration

### URL Scheme
- Scheme: `solana-wallet`
- Use: `solana-wallet://send?amount=0.1&to=ADDRESS`

### App Groups
- Identifier: `group.com.solanawallet.app`
- Used for: Widget data sharing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Contact

- GitHub: [@FlipZ3ro](https://github.com/FlipZ3ro)

Project Link: [https://github.com/FlipZ3ro/SolanaWallet](https://github.com/FlipZ3ro/SolanaWallet)
