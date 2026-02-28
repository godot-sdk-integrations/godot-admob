---
title: Testing
---

# <img src="../images/icon.png" width="24"> Testing

## Testing in Demo App

1. **Install plugin to demo:**
   ```bash
   ./script/build.sh -D
   ```

2. **Open demo project:**
   ```bash
   cd demo
   godot project.godot
   ```

3. **Configure test ads:**
   - Use test ad unit IDs from Google AdMob documentation
   - Edit `demo/main.gd` or relevant scene scripts

4. **Run and test features:**
   - Banner ads
   - Interstitial ads
   - Rewarded ads
   - App open ads
   - Native ads

## Android Testing

```bash
# Build and install
./script/build.sh -caD

# Export Android build from Godot
# Install on device/emulator
adb install demo/export/android/demo.apk

# View logs
adb logcat | grep -i AdmobPlugin
```

## iOS Testing (macOS only)

```bash
# Build and install
./script/build.sh -I -D

# Open in Xcode
cd demo
open ios/demo.xcodeproj

# Build and run on simulator/device from Xcode
```

## Automated Testing

Consider adding:
- Unit tests for native code
- Integration tests for ad loading
- UI tests for demo app
- CI/CD pipeline (GitHub Actions)