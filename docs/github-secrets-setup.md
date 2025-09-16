# GitHub Secrets Setup for Internal SOPS Distribution

## Required Secrets

Set up the following secrets in your GitHub repository settings:

### Apple Developer Signing
1. **`DEVELOPER_ID_P12_BASE64`**
   - Export your Developer ID Application certificate from Keychain Access as a .p12 file
   - Convert to base64: `base64 -i developer_id.p12 | pbcopy`
   - Paste the base64 string as the secret value

2. **`DEVELOPER_ID_P12_PASSWORD`**
   - The password you set when exporting the .p12 certificate

3. **`APPLE_DEVELOPER_ID`**
   - Your Developer ID Application certificate name (e.g., "Developer ID Application: HotelEngine Inc (TEAM_ID)")

4. **`APPLE_TEAM_ID`**
   - Your Apple Developer Team ID (10-character string)

5. **`APPLE_DEVELOPER_PASSWORD`**
   - App-specific password for notarization
   - Generate at: https://appleid.apple.com/account/manage
   - Use the Apple ID associated with your Developer account

### Homebrew Tap Access
6. **`HOMEBREW_TAP_GITHUB_TOKEN`**
   - GitHub Personal Access Token with `repo` permissions
   - Used to push updates to the homebrew-internal-tools repository

## Certificate Export Instructions

### 1. Export Developer ID Certificate from Keychain

```bash
# Find your Developer ID certificate
security find-identity -v -p codesigning

# Export the certificate (replace TEAM_ID with your actual team ID)
security export -t identities -f pkcs12 -P YOUR_PASSWORD \
  -o developer_id.p12 \
  "Developer ID Application: HotelEngine Inc (TEAM_ID)"

# Convert to base64 for GitHub secret
base64 -i developer_id.p12 | pbcopy
```

### 2. Verify Certificate Installation

```bash
# List available signing identities
security find-identity -v -p codesigning

# Should show something like:
# 1) ABC123... "Developer ID Application: HotelEngine Inc (TEAM_ID)"
```

## Testing Locally

You can test the signing process locally:

```bash
# Set environment variables
export APPLE_DEVELOPER_ID="Developer ID Application: HotelEngine Inc (TEAM_ID)"
export APPLE_DEVELOPER_PASSWORD="your-app-specific-password"
export APPLE_TEAM_ID="your-team-id"
export ENABLE_NOTARIZATION="true"

# Run GoReleaser in snapshot mode (no release)
goreleaser release --config .goreleaser-internal.yaml --snapshot --clean
```

## Troubleshooting

### Common Issues

1. **Certificate not found during signing**
   - Verify the certificate is properly imported
   - Check the certificate name matches exactly

2. **Notarization fails**
   - Ensure app-specific password is correct
   - Verify Team ID is accurate
   - Check that binary is properly signed before notarization

3. **Homebrew tap update fails**
   - Verify GitHub token has correct permissions
   - Ensure repository exists and is accessible
