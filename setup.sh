#!/bin/bash

# SolanaWallet Xcode Setup Script
# Run this on macOS to help configure the project

set -e

echo "🚀 SolanaWallet Xcode Setup"
echo "=========================="
echo ""

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ This script must be run on macOS"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -1)"
echo ""

# Project configuration
PROJECT_NAME="SolanaWallet"
BUNDLE_ID="com.solanawallet.app"
WIDGET_BUNDLE_ID="com.solanawallet.app.widget"
APP_GROUP="group.com.solanawallet.app"

echo "📋 Project Configuration:"
echo "   Project Name: $PROJECT_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Widget Bundle ID: $WIDGET_BUNDLE_ID"
echo "   App Group: $APP_GROUP"
echo ""

# Create Xcode project using xcodegen (if available)
if command -v xcodegen &> /dev/null; then
    echo "📦 XcodeGen found, generating project..."

    # Create xcodegen spec
    cat > project.yml << EOF
name: $PROJECT_NAME
options:
  bundleIdPrefix: com.solanawallet
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "15.0"
  createIntermediateGroups: true
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    TARGETED_DEVICE_FAMILY: "1,2"
    INFOPLIST_FILE: App/Info.plist
    CODE_SIGN_STYLE: Automatic

targets:
  $PROJECT_NAME:
    type: application
    platform: iOS
    sources:
      - path: App
      - path: Core
      - path: Features
      - path: Shared
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_ID
        INFOPLIST_FILE: App/Info.plist
        CODE_SIGN_ENTITLEMENTS: App/SolanaWallet.entitlements
    dependencies:
      - target: ${PROJECT_NAME}Widget
        embed: true
    scheme:
      testTargets: []

  ${PROJECT_NAME}Widget:
    type: app-extension
    platform: iOS
    sources:
      - path: Widget
      - path: Shared
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: $WIDGET_BUNDLE_ID
        INFOPLIST_FILE: Widget/Info.plist
        CODE_SIGN_ENTITLEMENTS: Widget/SolanaWalletWidget.entitlements
    dependencies: []

packages:
  SolanaSwift:
    url: https://github.com/AmirHosseinAghaei/SolanaSwift.git
    from: 3.0.0
  CryptoSwift:
    url: https://github.com/krzyzanowskicrypto/CryptoSwift.git
    from: 1.8.0
  KeychainAccess:
    url: https://github.com/kishikawakatsumi/KeychainAccess.git
    from: 4.2.0
EOF

    echo "✅ project.yml created"
    echo ""

    # Generate Xcode project
    echo "🔨 Generating Xcode project..."
    xcodegen generate
    echo "✅ Xcode project generated"
    echo ""

    # Open the project
    echo "📂 Opening Xcode project..."
    open "${PROJECT_NAME}.xcodeproj"

else
    echo "⚠️  XcodeGen not found"
    echo ""
    echo "To install XcodeGen:"
    echo "  brew install xcodegen"
    echo ""
    echo "Or create the project manually in Xcode:"
    echo ""
    echo "1. Open Xcode"
    echo "2. File > New > Project"
    echo "3. Choose: App (iOS)"
    echo "4. Product Name: $PROJECT_NAME"
    echo "5. Bundle Identifier: $BUNDLE_ID"
    echo "6. Interface: SwiftUI"
    echo "7. Language: Swift"
    echo "8. Save to: $(pwd)"
    echo ""
    echo "Then add the Widget extension:"
    echo "1. File > New > Target"
    echo "2. Choose: Widget Extension"
    echo "3. Product Name: ${PROJECT_NAME}Widget"
    echo "4. Bundle Identifier: $WIDGET_BUNDLE_ID"
    echo "5. Embed in App: Yes"
fi

echo ""
echo "📝 Post-Setup Configuration:"
echo ""
echo "1. Enable App Groups:"
echo "   - Select ${PROJECT_NAME} target"
echo "   - Signing & Capabilities > + Capability"
echo "   - Add: App Groups"
echo "   - Enable: $APP_GROUP"
echo ""
echo "   - Select ${PROJECT_NAME}Widget target"
echo "   - Signing & Capabilities > + Capability"
echo "   - Add: App Groups"
echo "   - Enable: $APP_GROUP"
echo ""
echo "2. Add URL Scheme:"
echo "   - Select ${PROJECT_NAME} target"
echo "   - Info > URL Types"
echo "   - Add URL Scheme: solana-wallet"
echo ""
echo "3. Add SPM Dependencies:"
echo "   - File > Add Package Dependencies"
echo "   - Add: https://github.com/AmirHosseinAghaei/SolanaSwift"
echo "   - Add: https://github.com/krzyzanowskicrypto/CryptoSwift"
echo "   - Add: https://github.com/kishikawakatsumi/KeychainAccess"
echo ""
echo "4. Configure Widget:"
echo "   - Select ${PROJECT_NAME}Widget target"
echo "   - General > Supported Destinations: iPhone, iPad"
echo "   - Info > Bundle display name: Solana Wallet Widget"
echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Build and run on simulator or device:"
echo "   xcodebuild -scheme $PROJECT_NAME -destination 'platform=iOS Simulator,name=iPhone 15'"
echo ""
