#!/bin/bash

# SolanaWallet Xcode Setup Script
# Run this on macOS to generate and open the Xcode project

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

PROJECT_NAME="SolanaWallet"
APP_GROUP="group.com.solanawallet.app"

# Check for project.yml
if [ ! -f project.yml ]; then
    echo "❌ project.yml not found"
    echo "Make sure you are in the SolanaWallet directory."
    exit 1
fi

# Generate Xcode project using XcodeGen
if command -v xcodegen &> /dev/null; then
    echo "📦 Generating Xcode project with XcodeGen..."
    xcodegen generate
    echo "✅ Xcode project generated"
    echo ""

    echo "📂 Opening Xcode project..."
    open "${PROJECT_NAME}.xcodeproj"
else
    echo "⚠️  XcodeGen not found. Install it with:"
    echo "  brew install xcodegen"
    echo ""
    echo "Then run this script again."
    exit 1
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
echo "3. Configure Widget:"
echo "   - Select ${PROJECT_NAME}Widget target"
echo "   - General > Supported Destinations: iPhone, iPad"
echo "   - Info > Bundle display name: Solana Wallet Widget"
echo ""
echo "✅ Setup complete!"
echo ""
echo "🚀 Build and run on simulator or device:"
echo "   xcodebuild -scheme $PROJECT_NAME -destination 'platform=iOS Simulator,name=iPhone 15'"
