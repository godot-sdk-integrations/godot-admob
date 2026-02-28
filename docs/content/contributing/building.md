---
title: Building
---

# <img src="../images/icon.png" width="24"> Building

There are three main build scripts located in the `script` directory.

- `build.sh` - the main build script
- `build_android.sh` - build script for Android platform
- `build_ios.sh` - build script for iOS platform

## <img src="../images/icon.png" width="20"> Cross-Platform Builds

Cross-platform builds with the `build.sh` script.

### Build Options

| Option | Description |
|--------|-------------|
| `-a` | Build plugin for Android platform (`-a -- -h` for all options) |
| `-i` | Build plugin for iOS platform (`-i -- -h` for all options) |
| `-c` | Remove existing builds |
| `-C` | Remove existing builds and archives |
| `-d` | Uninstall plugin from demo app |
| `-D` | Install plugin to demo app |
| `-A` | Create Android relese archive |
| `-I` | Create iOS relese archive |
| `-M` | Create multi-platform relese archive |
| `-R` | Create all relese archives |

### Output Locations

- **GDScript code:** `addon/build/output/`
- **Debug AAR:** `android/build/outputs/aar/*-debug.aar`
- **Release AAR:** `android/build/outputs/aar/*-release.aar`
- **Built plugin:** `common/build/plugin/`
- **Release archive:** `release/PluginTemplatePlugin-*-v*.zip`

## <img src="../images/icon.png" width="20"> Android Builds

### Quick Reference

```bash
# Clean and build Android debug
./script/build.sh -a -- -cb

**Note:** Options after `--` are passed to `build_android.sh`

# Clean and build Android release
./script/build.sh -a -- -cbr

# Install Android plugin to demo app
./script/build_android.sh -D

# Uninstall Android plugin from demo app
./script/build_android.sh -d

# Create Android release archive
./script/build_android.sh -R
```

### Build Options

| Option | Description |
|--------|-------------|
| `-b` | Build plugin for Android platform (debug build variant by default) |
| `-c` | Clean Android build |
| `-d` | Uninstall Android plugin from demo app |
| `-D` | Install Android plugin to demo app |
| `-h` | Display script usage information |
| `-r` | Build Android plugin with release build variant |
| `-R` | Create Android relese archive |

### Android Studio

If using Android Studio, make sure to open the root Gradle project from the `common` directory.

## <img src="../images/icon.png" width="20"> iOS Builds

### Quick Reference

```bash
# Clean and rebuild iOS
./script/build.sh -i -- -cb

**Note:** Options after `--` are passed to `build_ios.sh`

# Full build (first time - downloads Godot)
./script/build_ios.sh -A

# Clean and rebuild (reuses Godot)
./script/build_ios.sh -ca

# Full clean rebuild (removes Godot)
./script/build_ios.sh -cgA

# Build and create archive
./script/build_ios.sh -cbz

# Custom timeout for header generation (seconds)
./script/build_ios.sh -H -t 60
```

### Build Options

| Option | Description |
|--------|-------------|
| `-a` | Generate headers, add packages, and build |
| `-A` | Download Godot + full build |
| `-b` | Build plugin only |
| `-c` | Clean existing build |
| `-g` | Remove Godot directory |
| `-G` | Download Godot |
| `-h` | Display help |
| `-H` | Generate Godot headers |
| `-p` | Remove SPM packages |
| `-P` | Add SPM packages |
| `-R` | Create release archive |
| `-t <seconds>` | Set header generation timeout |

### Build Process Explained

The iOS build process involves several steps:

1. **Download Godot** (if needed):
   - Downloads the official Godot binary from GitHub
   - Version specified in `config.properties`
   - Extracted to `ios/godot/` by default, or to the path set by `godot.dir` in `common/local.properties`

2. **Generate Headers**:
   - Starts a Godot build to generate C++ headers
   - Timeout prevents full Godot build (we only need headers)
   - Default timeout: 40 seconds (increase if needed)

3. **Add Swift Packages**:
   - Downloads ad network SDKs via Swift Package Manager
   - Adds mediation adapters as package dependencies
   - Resolves package dependencies for Xcode

4. **Build XCFrameworks**:
   - Builds for iOS device (arm64)
   - Builds for iOS simulator (arm64, x86_64)
   - Creates universal XCFrameworks for debug and release

### Output Locations

- **Godot source:** `ios/godot/` (default) or path set by `godot.dir` in `common/local.properties`
- **Build artifacts:** `ios/build/`
- **Frameworks:** `ios/build/framework/`
- **Archives:** `ios/build/lib/*.xcarchive`
- **Release archive:** `release/PluginTemplatePlugin-iOS-v*.zip`