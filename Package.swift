// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SolanaWallet",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SolanaWallet",
            targets: ["SolanaWallet"]
        )
    ],
    targets: [
        .target(
            name: "SolanaWallet",
            dependencies: []
        )
    ]
)
