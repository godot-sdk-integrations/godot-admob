---
title: Building
icon: fontawesome/solid/hammer
---

# <img src="../images/icon.png" width="24"> Building

There are three main build scripts located in the `script` directory.

| Script | Description |
|--------|-------------|
| `build.sh` | the main build script |
| `build_android.sh` | build script for Android platform |
| `build_ios.sh` | build script for iOS platform |

## <img src="../images/icon.png" width="24">  Cross-Platform Builds

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
| `-f` | Fix source code format issues |
| `-A` | Create Android release archive |
| `-I` | Create iOS release archive |
| `-M` | Create multi-platform release archive |
| `-R` | Create all release archives |
| `-v` | Verify source code format compliance |

### Output Locations

| Output | Location |
|--------|----------|
| **GDScript code:** | `addon/build/output/`|
| **Debug AAR:** | `android/build/outputs/aar/*-debug.aar` |
| **Release AAR:** | `android/build/outputs/aar/*-release.aar` |
| **Built plugin:** | `common/build/plugin/` |
| **Release archive:** | `release/AdmobPlugin-*-v*.zip` |

## <img src="../images/icon.png" width="20">  Android Builds

### Quick Reference

```bash
# Clean and build Android debug
./script/build.sh -a -- -cb

!!! note
   Options after `--` are passed to `build_android.sh`

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
| `-R` | Create Android release archive |

### Android Studio

If using Android Studio, make sure to open the root Gradle project from the `common` directory.

## <img src="../images/icon.png" width="24">  iOS Builds

### Quick Reference

```bash
# Clean and run iOS debug build
./script/build.sh -i -- -cb

!!! note
   Options after `--` are passed to `build_ios.sh`

# Full build (first time - downloads Godot headers automatically)
./script/build_ios.sh -A

# Clean and rebuild (reuses existing Godot headers)
./script/build_ios.sh -ca

# Full clean rebuild (removes Godot headers directory first)
./script/build_ios.sh -cgA

# Clean, build and create archive
./script/build_ios.sh -cR

# Debug build for simulator
./script/build_ios.sh -bs

# Release build for simulator
./script/build_ios.sh -Bs

# Install iOS plugin to demo app
./script/build_ios.sh -D

# Uninstall iOS plugin from demo app
./script/build_ios.sh -d

# Resolve SPM dependencies only
./script/build_ios.sh -r
```

### Build Options

| Option | Description |
|--------|-------------|
| `-a` | Update SPM packages and build both debug and release variants |
| `-A` | Download Godot headers, update SPM packages, and build both debug and release variants |
| `-b` | Run debug build (device); combine with `-s` for simulator |
| `-B` | Run release build (device); combine with `-s` for simulator |
| `-c` | Clean existing build |
| `-d` | Uninstall iOS plugin from demo app |
| `-D` | Install iOS plugin to demo app |
| `-g` | Remove Godot headers directory |
| `-G` | Download Godot headers |
| `-h` | Display help |
| `-p` | Remove SPM packages and build artifacts |
| `-P` | Add SPM packages from configuration |
| `-r` | Resolve SPM dependencies |
| `-R` | Create release archive |
| `-s` | Simulator build; use with `-b` for simulator debug, `-B` for simulator release |

### Build Process Explained

The iOS build process involves several steps that are orchestrated automatically:

1. **Download Godot Headers** (if needed):
    - Downloads a pre-built Godot headers archive from `github.com/godot-mobile-plugins/godot-headers`
    - Version is determined by `godotVersion` and `godotReleaseType` in `godot.properties`
    - Extracted to `ios/godot/` by default, or to the path set by `godot.dir` in `common/local.properties`
    - The download is skipped if the correct version is already present (checked via a `GODOT_VERSION` file)
    - If the directory exists but contains a different version, the build fails with a clear error - run `./script/build_ios.sh -gG` to switch versions

2. **Validate Swift Version**:
    - Reads `swift_version` from `ios/config/ios.properties`
    - Fails early with a clear error if the property is missing or blank
    - Syncs the version into `plugin.xcodeproj/project.pbxproj` automatically

3. **Validate Godot Version**:
    - Confirms the `GODOT_VERSION` file in the Godot headers directory matches `godotVersion` in `godot.properties`

4. **Update & Resolve SPM Packages**:
    - Reads dependency definitions from `ios/config/spm_dependencies.json`
    - Injects package references into the Xcode project via `script/spm_manager.rb` (requires Ruby and the `xcodeproj` gem)
    - Resolves the packages with `xcodebuild -resolvePackageDependencies`
5. **Build XCFrameworks**:
    - Builds up to four variants via `xcodebuild archive`:
     
   | Build Target                 | Platform  | Architecture       | Configuration |
   |-----------------------------|-----------|--------------------|---------------|
   | `buildiOSDebug`             | Device    | `arm64`            | Debug         |
   | `buildiOSRelease`           | Device    | `arm64`            | Release       |
   | `buildiOSDebugSimulator`    | Simulator | `arm64` / `x86_64` | Debug         |
   | `buildiOSReleaseSimulator`  | Simulator | `arm64` / `x86_64` | Release       |

   - The `-s` flag selects simulator variants; without it, device variants are built
   - Archives are created as `.xcarchive` bundles under `ios/build/lib/`
   - XCFrameworks combining device and simulator slices are assembled in `ios/build/framework/`
   - **Only the plugin's own xcframeworks** (`PluginName.debug.xcframework`, `PluginName.release.xcframework`) are copied into the plugin directory and included in release archives
   - SPM dependency xcframeworks produced in `ios/build/DerivedData/` are **not** bundled in the archive; they are resolved by Xcode at Godot iOS export time using the `Package.resolved` file that is committed alongside the Xcode project

### Output Locations

- **Godot headers:** `ios/godot/` (default) or path set by `godot.dir` in `common/local.properties`
- **Build artifacts:** `ios/build/`
- **xcarchives:** `ios/build/lib/ios_debug.xcarchive`, `ios_release.xcarchive`, `sim_debug.xcarchive`, `sim_release.xcarchive`
- **Plugin XCFrameworks:** `ios/build/framework/AdmobPlugin.debug.xcframework`, `AdmobPlugin.release.xcframework`
- **Release archive:** `release/AdmobPlugin-iOS-v*.zip`

!!! note
   Release archives (iOS and Multi) contain only the plugin's own xcframeworks. SPM dependency xcframeworks are intentionally excluded - they are fetched and linked by Xcode at Godot iOS export time using the `Package.resolved` committed with the Xcode project.
