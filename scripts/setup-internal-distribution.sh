#!/bin/bash
set -euo pipefail

# HotelEngine SOPS Fork - Internal Distribution Setup Script
# This script helps set up the complete internal distribution pipeline

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOMEBREW_TAP_REPO="hotelengine/homebrew-internal-tools"

echo "🚀 Setting up HotelEngine SOPS Internal Distribution"
echo "=================================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed."
    echo "   Install with: brew install gh"
    exit 1
fi

if ! command -v goreleaser &> /dev/null; then
    echo "❌ GoReleaser is required but not installed."
    echo "   Install with: brew install goreleaser"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo "   Run: gh auth login"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Check if we're in the right repository
if [[ ! -f "$REPO_ROOT/.goreleaser-internal.yaml" ]]; then
    echo "❌ This script must be run from the SOPS repository root"
    exit 1
fi

echo "📁 Repository root: $REPO_ROOT"

# Function to check if repository exists
check_repo_exists() {
    local repo="$1"
    if gh repo view "$repo" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Set up Homebrew tap repository
echo ""
echo "🍺 Setting up Homebrew tap repository..."

if check_repo_exists "$HOMEBREW_TAP_REPO"; then
    echo "✅ Homebrew tap repository already exists: $HOMEBREW_TAP_REPO"
else
    echo "📝 Creating Homebrew tap repository: $HOMEBREW_TAP_REPO"
    
    read -p "   Create the repository? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh repo create "$HOMEBREW_TAP_REPO" \
            --private \
            --description "Internal Homebrew tap for HotelEngine tools" \
            --clone
        
        cd "homebrew-internal-tools"
        
        # Set up initial structure
        mkdir -p Casks Formula
        
        cat > README.md << 'EOF'
# HotelEngine Internal Tools Homebrew Tap

This tap contains internal tools for HotelEngine development.

## Installation

```bash
# Add the tap
brew tap hotelengine/internal-tools

# Install tools
brew install --cask sops-hotelengine
```

## Available Tools

- **sops-hotelengine**: HotelEngine fork of SOPS (Secrets OPerationS)
EOF
        
        git add .
        git commit -m "Initial tap structure"
        git push origin main
        
        cd "$REPO_ROOT"
        rm -rf homebrew-internal-tools
        
        echo "✅ Homebrew tap repository created successfully"
    else
        echo "⏭️  Skipping Homebrew tap repository creation"
    fi
fi

# Check GitHub secrets
echo ""
echo "🔐 Checking GitHub repository secrets..."

REQUIRED_SECRETS=(
    "DEVELOPER_ID_P12_BASE64"
    "DEVELOPER_ID_P12_PASSWORD"
    "APPLE_DEVELOPER_ID"
    "APPLE_TEAM_ID"
    "APPLE_DEVELOPER_PASSWORD"
    "HOMEBREW_TAP_GITHUB_TOKEN"
)

MISSING_SECRETS=()

for secret in "${REQUIRED_SECRETS[@]}"; do
    if ! gh secret list | grep -q "^$secret"; then
        MISSING_SECRETS+=("$secret")
    fi
done

if [[ ${#MISSING_SECRETS[@]} -eq 0 ]]; then
    echo "✅ All required secrets are configured"
else
    echo "⚠️  Missing secrets:"
    for secret in "${MISSING_SECRETS[@]}"; do
        echo "   - $secret"
    done
    echo ""
    echo "📖 See docs/github-secrets-setup.md for setup instructions"
fi

# Test local build
echo ""
echo "🔧 Testing local build..."

if go version &> /dev/null; then
    echo "   Running GoReleaser snapshot build..."
    if goreleaser release --config .goreleaser-internal.yaml --snapshot --clean --skip=sign,notarize; then
        echo "✅ Local build successful"
        echo "   Built artifacts in dist/ directory"
    else
        echo "❌ Local build failed"
        echo "   Check your Go installation and dependencies"
    fi
else
    echo "⚠️  Go not installed, skipping local build test"
fi

# Summary
echo ""
echo "📋 Setup Summary"
echo "==============="
echo "✅ Prerequisites installed"
echo "✅ GoReleaser configuration ready (.goreleaser-internal.yaml)"
echo "✅ GitHub Actions workflow ready (.github/workflows/internal-release.yml)"

if check_repo_exists "$HOMEBREW_TAP_REPO"; then
    echo "✅ Homebrew tap repository exists"
else
    echo "⚠️  Homebrew tap repository needs to be created"
fi

if [[ ${#MISSING_SECRETS[@]} -eq 0 ]]; then
    echo "✅ GitHub secrets configured"
else
    echo "⚠️  GitHub secrets need configuration"
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Configure missing GitHub secrets (see docs/github-secrets-setup.md)"
echo "2. Create a release tag: git tag v3.8.1-he && git push origin v3.8.1-he"
echo "3. Watch GitHub Actions build and publish the release"
echo "4. Test installation: brew tap hotelengine/internal-tools && brew install --cask sops-hotelengine"
echo ""
echo "📚 Documentation:"
echo "   - docs/internal-distribution.md - Complete usage guide"
echo "   - docs/github-secrets-setup.md - Secrets configuration"
echo "   - docs/homebrew-tap-setup.md - Manual tap setup"
echo ""
echo "🎉 Setup complete!"
