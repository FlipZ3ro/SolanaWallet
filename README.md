# SolanaWallet

> Native iOS Solana wallet — zero dependencies, maximum security.

![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=flat-square&logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift_5.9-F05138?style=flat-square&logo=swift&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-00F584?style=flat-square)
![Dependencies](https://img.shields.io/badge/Dependencies-Zero-00F584?style=flat-square)

---

## What is this?

A non-custodial Solana wallet for iOS with **WidgetKit integration** — check balances and send SOL straight from your home screen. Built entirely on Apple's native frameworks. No third-party SDKs, no bloated dependencies.

## Features

- 🔐 **Non-custodial** — keys never leave your device
- 💸 **Send SOL** — with Face ID confirmation
- 📥 **Receive** — QR code + address copy
- 📊 **Token balances** — SOL and SPL tokens
- 📱 **Home Screen Widget** — quick balance, quick send
- 🔒 **Secure Enclave** — private key storage on hardware
- 🧬 **App Intents** — widget-to-app handoff for signing

## Security

| Layer | Implementation |
|-------|----------------|
| Private keys | Secure Enclave (hardware-backed) |
| Secrets storage | iOS Keychain |
| Transaction signing | Face ID / Touch ID |
| Widget access | Read-only — cannot sign |
| Inter-app | App Groups + Keychain Sharing |

## Architecture

```
┌─────────────────────────────────────────────┐
│                  SolanaWallet                │
├──────────┬──────────┬───────────┬───────────┤
│   App    │   Core   │ Features  │  Widget   │
│          │          │           │           │
│ Entry    │ Wallet   │ Dashboard │ Balance   │
│ Routing  │ Solana   │ Send      │ Quick Send│
│ State    │ Security │ Receive   │ Intents   │
│          │          │ History   │           │
│          │          │ Settings  │           │
└──────────┴──────────┴───────────┴───────────┘
       │          │          │          │
       ▼          ▼          ▼          ▼
   SwiftUI   CryptoKit   Security   AppIntents
              (native)   (native)   (native)
```

## Tech Stack

| Component | Framework |
|-----------|-----------|
| UI | SwiftUI |
| Crypto | CryptoKit |
| Keychain | Security framework |
| Auth | LocalAuthentication |
| Networking | URLSession + JSON-RPC |
| Widget | WidgetKit + AppIntents |
| State | @Observable (iOS 17+) |

> **100% native.** Zero third-party packages.

## Getting Started

```bash
git clone https://github.com/FlipZ3ro/SolanaWallet.git
cd SolanaWallet
brew install xcodegen   # if not installed
./setup.sh              # generates .xcodeproj from project.yml
```

Then in Xcode:
1. Select both targets → Signing & Capabilities → **+ App Groups**
2. Enable `group.com.solanawallet.app`
3. ⌘R

## Deep Links

```
solana-wallet://send?amount=0.1&to=ADDRESS
solana-wallet://receive
solana-wallet://swap
```

## License

MIT — see [LICENSE](LICENSE).

---

[@FlipZ3ro](https://github.com/FlipZ3ro) · [GitHub](https://github.com/FlipZ3ro/SolanaWallet)
