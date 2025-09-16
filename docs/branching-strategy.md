# HotelEngine SOPS Fork - Branching Strategy

## Branch Overview

This document outlines the branching strategy for managing HotelEngine's SOPS fork, balancing upstream synchronization with internal feature development.

### 🌳 Branch Structure

```
upstream/main  ←─ (sync)   ─── main
                             │
                             ├── internal-distribution  (release infrastructure)
                             │
                             ├── feature/your-feature-name  (new SOPS features)
                             │
                             └── hotelengine-main  (integration branch)
                                      │
                                      └── v3.8.1-he  (release tags)
```

### 📋 Branch Descriptions

#### `main`
- **Purpose**: Mirror of upstream SOPS with minimal changes
- **Usage**: Sync point for upstream updates
- **Merge Policy**: Only fast-forward merges from upstream
- **Protection**: Should stay as close to upstream as possible

#### `internal-distribution`
- **Purpose**: Contains all internal release infrastructure
- **Contents**: 
  - `.goreleaser-internal.yaml`
  - `.github/workflows/internal-release.yml`
  - Documentation (`docs/`)
  - Setup scripts (`scripts/`)
- **Merge Target**: `hotelengine-main`

#### `feature/your-feature-name`
- **Purpose**: Individual feature development
- **Examples**: 
  - `feature/aws-publishing-support`
  - `feature/kubernetes-secrets-integration`
  - `feature/enhanced-logging`
- **Base**: `main` branch
- **Merge Target**: `hotelengine-main`

#### `hotelengine-main`
- **Purpose**: Integration branch combining all HotelEngine features
- **Contents**: All internal features + distribution infrastructure
- **Usage**: Source for creating release tags
- **Release Tags**: `v3.8.1-he`, `v3.9.0-he.1`, etc.

## 🔄 Workflow Processes

### 1. Adding a New Feature

```bash
# Start from clean main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/my-new-feature

# Develop your feature
# ... make changes ...
git add . && git commit -m "feat: add new feature"

# Push feature branch
git push origin feature/my-new-feature

# Create PR: feature/my-new-feature → hotelengine-main
```

### 2. Updating Internal Distribution

```bash
# Switch to internal-distribution branch
git checkout internal-distribution

# Make infrastructure changes
# ... update GoReleaser config, docs, etc ...
git add . && git commit -m "feat: update release infrastructure"

# Push changes
git push origin internal-distribution

# Create PR: internal-distribution → hotelengine-main
```

### 3. Syncing with Upstream

```bash
# Update main branch
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Rebase feature branches if needed
git checkout feature/my-feature
git rebase main

# Update integration branch
git checkout hotelengine-main
git merge main
```

### 4. Creating a Release

```bash
# Ensure hotelengine-main is up to date
git checkout hotelengine-main
git merge internal-distribution
git merge feature/my-feature  # for each completed feature

# Test the integration
make test
goreleaser release --snapshot --clean

# Create and push release tag
git tag v3.8.1-he
git push origin v3.8.1-he

# GitHub Actions will automatically build and release
```

## 🔧 Branch Management Commands

### Quick Setup for New Contributors

```bash
# Clone the repository
git clone https://github.com/hotelengine/sops.git
cd sops

# Add upstream remote
git remote add upstream https://github.com/getsops/sops.git

# Fetch all branches
git fetch --all

# Set up local tracking branches
git checkout -b internal-distribution origin/internal-distribution
git checkout -b hotelengine-main origin/hotelengine-main
git checkout main
```

### Regular Maintenance

```bash
# Weekly upstream sync
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Update integration branch
git checkout hotelengine-main
git merge main
git push origin hotelengine-main
```

## 📦 Release Management

### Version Naming Convention

- **Format**: `v{upstream-version}-he[.patch]`
- **Examples**:
  - `v3.8.1-he` - First HotelEngine release based on SOPS v3.8.1
  - `v3.8.1-he.1` - Second HotelEngine release (additional patches)
  - `v3.9.0-he` - HotelEngine release based on SOPS v3.9.0

### Release Checklist

- [ ] All features merged to `hotelengine-main`
- [ ] Internal distribution infrastructure updated
- [ ] Documentation updated
- [ ] Local tests pass
- [ ] GoReleaser snapshot build successful
- [ ] Release tag created and pushed
- [ ] GitHub Actions build completes
- [ ] Homebrew tap updated automatically
- [ ] Installation tested on clean machine

## 🚨 Merge Conflicts Resolution

### When Upstream Changes Conflict with Features

1. **Update main**: `git checkout main && git merge upstream/main`
2. **Rebase feature**: `git checkout feature/my-feature && git rebase main`
3. **Resolve conflicts** in feature branch
4. **Update integration**: `git checkout hotelengine-main && git merge feature/my-feature`

### When Internal Infrastructure Conflicts

1. Update infrastructure in `internal-distribution` branch first
2. Merge to `hotelengine-main`
3. Resolve any conflicts there

## 🔒 Branch Protection Rules

Recommended GitHub branch protection settings:

### `main`
- ✅ Require pull request reviews
- ✅ Dismiss stale reviews
- ✅ Require status checks (CI)
- ✅ Restrict pushes to admins only

### `hotelengine-main`
- ✅ Require pull request reviews
- ✅ Require status checks (CI)
- ✅ Allow force pushes (for clean integration)

### `internal-distribution`
- ✅ Require pull request reviews
- ✅ Require status checks (CI)

## 💡 Best Practices

### Feature Development
- Keep features focused and atomic
- Write tests for new functionality
- Update documentation
- Consider upstream contribution potential

### Release Management
- Test releases in staging environment first
- Maintain backward compatibility when possible
- Document breaking changes clearly
- Keep detailed changelog

### Upstream Relationship
- Regularly sync with upstream
- Consider contributing non-HE-specific features back
- Monitor upstream for security updates
- Participate in upstream community when relevant

## 🔍 Troubleshooting

### Common Issues

1. **Merge conflicts during upstream sync**
   - Resolve in feature branches first
   - Then update integration branch

2. **Release build failures**
   - Test with `goreleaser release --snapshot` first
   - Check Apple Developer certificate status
   - Verify GitHub secrets are current

3. **Homebrew tap not updating**
   - Check GitHub token permissions
   - Verify tap repository exists and is accessible
   - Review GoReleaser logs for errors

### Getting Help

- Check GitHub Actions logs for build issues
- Review GoReleaser documentation for release problems
- Contact DevOps team for certificate/signing issues
- Use `git log --oneline --graph` to visualize branch history
