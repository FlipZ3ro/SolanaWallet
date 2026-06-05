#!/bin/bash

# Push SolanaWallet to GitHub
# Run this script on your machine

set -e

echo "🚀 Pushing SolanaWallet to GitHub"
echo "=================================="
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo ""
    echo "Install it:"
    echo "  macOS: brew install gh"
    echo "  Linux: sudo apt install gh"
    echo "  Windows: winget install GitHub.cli"
    echo ""
    echo "Or download from: https://cli.github.com/"
    exit 1
fi

echo "✅ GitHub CLI found: $(gh --version | head -1)"

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo ""
    echo "Please authenticate first:"
    echo "  gh auth login"
    exit 1
fi

echo "✅ Authenticated as: $(gh api user --jq '.login')"
echo ""

# Change to project directory
cd "$(dirname "$0")"
echo "📂 Working directory: $(pwd)"
echo ""

# Initialize git if not already
if [ ! -d ".git" ]; then
    echo "📦 Initializing git repository..."
    git init
fi

# Add all files
echo "📝 Adding files to git..."
git add .

# Commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: SolanaWallet iOS app with Widget

Features:
- Solana wallet (create/import)
- Send/Receive SOL
- Face ID authentication
- Widget for balance display
- Quick send from widget
- Transaction history
- Secure key storage (Keychain + Secure Enclave)

Tech Stack:
- Swift 5.9+
- SwiftUI
- WidgetKit
- AppIntents
- LocalAuthentication (Face ID)

Security:
- Private key stored in Secure Enclave
- Widget is read-only (cannot sign transactions)
- Face ID required for all transactions
- App Groups for widget-app communication"

# Check if remote exists
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    echo "🔗 Creating GitHub repository..."

    # Get repo name from current directory
    REPO_NAME=$(basename "$(pwd)")
    REPO_DESC="Solana wallet iOS app with Widget - Secure, Face ID, Quick Send from Widget"

    # Create repo
    gh repo create "$REPO_NAME" \
        --public \
        --description "$REPO_DESC" \
        --source=. \
        --push

    echo "✅ Repository created and pushed!"
else
    echo "🔗 Remote already exists: $REMOTE_URL"
    echo "📤 Pushing to remote..."
    git push -u origin main
fi

echo ""
echo "✅ Done! Your code is on GitHub!"
echo ""
echo "🔗 View your repository:"
echo "   https://github.com/$(gh api user --jq '.login')/$(basename "$(pwd)")"
echo ""
echo "📋 Next steps:"
echo "   1. Enable GitHub Actions for CI/CD"
echo "   2. Add collaborators if needed"
echo "   3. Set up branch protection rules"
echo "   4. Create releases for versioning"
echo ""
