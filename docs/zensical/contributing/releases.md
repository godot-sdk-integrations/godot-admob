---
title: Releases
---

# <img src="../images/icon.png" width="24"> Creating Releases

## Full Multi-Platform Release

```bash
# Create all release archives
./script/build.sh -R
```

This creates:
- `release/AdmobPlugin-Android-v*.zip`
- `release/AdmobPlugin-iOS-v*.zip`
- `release/AdmobPlugin-Multi-v*.zip` (combined)

## Platform-Specific Releases

```bash
# Create all release archives
./script/build.sh -R

# Create only Android release archive
./script/build.sh -A

# Create only iOS release archive
./script/build.sh -I

# Create only multi-platform release archive
./script/build.sh -M
```

## Release Checklist

- [ ] Update version in `common/config/config.properties`
- [ ] Update versions in issue templates (`.github/ISSUE_TEMPLATE`)
- [ ] Test on both platforms
- [ ] Build release archives
- [ ] Create GitHub release
- [ ] Upload archives to release & publish
- [ ] Close GitHub milestone
- [ ] Post GitHub announcement
- [ ] Update Asset Library listing
- [ ] Update Asset Store listing