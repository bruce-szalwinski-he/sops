# HotelEngine SOPS Fork - Internal Distribution Guide

## Overview

This document outlines the complete process for building, signing, and distributing the HotelEngine fork of SOPS internally using Homebrew.

## Quick Start for End Users

### Installation via Homebrew (Recommended)

```bash
# Add the HotelEngine tap (one-time setup)
brew tap hotelengine/internal-tools

# Install SOPS HotelEngine fork
brew install --cask sops-hotelengine

# Verify installation
sops-hotelengine --version
```

### Manual Installation

```bash
# Download latest release
curl -LO https://github.com/hotelengine/sops/releases/latest/download/sops-hotelengine-darwin-universal.zip

# Extract and install
unzip sops-hotelengine-darwin-universal.zip
sudo mv sops-hotelengine /usr/local/bin/
sudo chmod +x /usr/local/bin/sops-hotelengine

# Verify installation
sops-hotelengine --version
```

## Release Process

### Creating a New Release

1. **Tag the release** with HotelEngine suffix:
   ```bash
   git tag v3.8.1-he
   git push origin v3.8.1-he
   ```

2. **GitHub Actions will automatically**:
   - Build the universal macOS binary
   - Sign with Apple Developer ID
   - Notarize with Apple
   - Create GitHub release
   - Update Homebrew tap

3. **Users can then update**:
   ```bash
   brew upgrade --cask sops-hotelengine
   ```

### Version Naming Convention

- Use upstream version + `-he` suffix
- Examples: `v3.8.1-he`, `v3.9.0-he.1` (for additional patches)

## Architecture Details

### Build Process
- **Platform**: macOS universal binary (Intel + Apple Silicon)
- **Signing**: Apple Developer ID Application certificate
- **Notarization**: Apple notarization for Gatekeeper compatibility
- **Distribution**: GitHub Releases + Homebrew Cask

### Security Features
- Code signing ensures binary integrity
- Notarization provides Gatekeeper compatibility
- Checksums for verification
- All artifacts are signed and traceable

## Development Workflow

### Local Testing

```bash
# Test build locally
make release-snapshot

# Test signing locally (requires certificates)
goreleaser release --config .goreleaser-internal.yaml --snapshot --clean
```

### Fork Maintenance

1. **Sync with upstream**:
   ```bash
   git remote add upstream https://github.com/getsops/sops.git
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Apply HotelEngine-specific changes**
3. **Test thoroughly**
4. **Create release tag**

## Repository Structure

```
sops/
├── .goreleaser-internal.yaml     # Internal release configuration
├── .github/workflows/
│   └── internal-release.yml      # GitHub Actions for releases
├── docs/
│   ├── homebrew-tap-setup.md     # Homebrew tap setup guide
│   ├── github-secrets-setup.md   # GitHub secrets configuration
│   └── internal-distribution.md  # This document
└── [rest of SOPS files]
```

## External Dependencies

### Required Repositories
- **Main Fork**: `hotelengine/sops` (this repository)
- **Homebrew Tap**: `hotelengine/homebrew-internal-tools`

### Required Secrets
- Apple Developer certificates and credentials
- GitHub token for Homebrew tap updates

## Troubleshooting

### Common Issues

1. **Installation fails with "unsigned binary"**
   - Verify binary is properly signed and notarized
   - Check Apple Developer credentials

2. **Homebrew tap not found**
   - Ensure `hotelengine/homebrew-internal-tools` repository exists
   - Verify repository is accessible to team members

3. **Version conflicts**
   - Use unique version tags with `-he` suffix
   - Avoid conflicts with upstream SOPS versions

### Support

For issues with the internal distribution:
1. Check GitHub Actions logs
2. Verify Apple Developer account status
3. Test local builds first
4. Contact DevOps team for certificate/signing issues

## Future Considerations

### Upstream Integration
- Consider contributing changes back to upstream SOPS
- Maintain compatibility with upstream versions
- Document any HotelEngine-specific modifications

### Alternative Distribution
- Consider additional distribution methods if needed
- Docker containers for CI/CD environments
- Direct binary distribution for non-macOS platforms
