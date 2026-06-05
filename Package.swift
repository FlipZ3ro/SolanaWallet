// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SolanaWallet",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SolanaWallet",
            targets: ["SolanaWallet"]
        )
    ],
    dependencies: [
        // Solana Swift SDK
        .package(url: "https://github.com/AmirHosseinAghaei/SolanaSwift.git", from: "3.0.0"),

        // Crypto
        .package(url: "https://github.com/krzyzanowskicrypto/CryptoSwift.git", from: "1.8.0"),

        // Keychain
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),

        // QR Code
        .package(url: "https://github.com/AliRn75/QRCode.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SolanaWallet",
            dependencies: [
                "SolanaSwift",
                "CryptoSwift",
                "KeychainAccess",
                "QRCode"
            ]
        )
    ]
)
