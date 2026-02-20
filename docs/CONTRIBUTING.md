# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="28"> Contributing

Thank you for your interest in contributing to the Godot AdMob Plugin! This guide will help you understand the project structure, build processes, and development workflows.

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Table of Contents

- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Configuration](#-configuration)
- [Development Workflow](#-development-workflow)
- [Building](#-building)
- [Testing](#-testing)
- [Creating Releases](#-creating-releases)
- [Installation](#-installation)
- [Troubleshooting](#-troubleshooting)
- [Contributing Guidelines](#-contributing-guidelines)

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Project structure

```text
.
├── addon/                              # GDScript addon module
│   ├── build.gradle.kts               # Gradle build configuration
│   ├── config.gradle.kts              # Gradle configuration
│   ├── ?.gradle.kts                   # Any extra Gradle configuration (configured in
│   │                                  # common/config/config.properties) for the plugin goes here
│   ├── build/
│   │   └── output/                    # Generated GDScript code
│   └── src/                           # GDScript templates
│
├── android/                            # Android platform module
│   ├── build.gradle.kts               # Android build configuration
│   ├── config.gradle.kts              # Android configuration
│   ├── build/
│   │   └── outputs/                   # Generated Android AAR files
│   ├── libs/                          # Godot library for Android
│   └── src/main/                      # Android source code
│
├── common/                             # Shared build configuration
│   ├── build.gradle.kts               # Root build configuration
│   ├── config.gradle.kts              # Common configuration
│   ├── gradle.properties              # Gradle properties
│   ├── local.properties               # Local machine config (gitignored)
│   ├── settings.gradle.kts            # Gradle settings
│   ├── build/
│   │   ├── archive/                   # Generated archives
│   │   ├── plugin/                    # Built plugin files
│   │   └── reports/                   # Build reports
│   ├── config/
│   │   ├── config.properties          # Common plugin configuration
│   │   └── mediation.properties       # Ad mediation configuration
│   └── gradle/                        # Gradle wrapper and version catalogs
│       └── libs.versions.toml         # Dependencies and versions
│
├── demo/                               # Demo application
│   ├── addons/                        # Installed plugin files
│   ├── ios/                           # iOS-specific demo files
│   └── *.gd                           # Demo app scripts
│
├── ios/                                # iOS platform module
│   ├── src/                           # iOS platform code
│   ├── admob_plugin.xcodeproj/        # Xcode project
│   ├── build/                         # iOS build outputs
│   ├── config/
│   │   ├── config.properties          # iOS configuration
│   │   └── *.gdip                     # Godot iOS plugin config
│   └── .godot/                        # Downloaded Godot source (default location; configurable via local.properties)
│
├── script/                             # Build and utility scripts
│   ├── build.sh                       # Main build script
│   ├── build_ios.sh                   # iOS build script
│   ├── install.sh                     # Plugin installation script
│   ├── run_gradle_task.sh             # Gradle task runner
│   └── get_config_property.sh         # Configuration reader
│
├── docs/                               # Documentation
└── release/                            # Final release archives
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Prerequisites

### General Requirements
- **Git** - For version control
- **Bash** - For running build scripts (macOS/Linux native, Windows via WSL or Git Bash)

### Android Development
- **Java Development Kit (JDK)** - Version 17 or higher
- **Android SDK** - With the following components:
  - Android SDK Platform Tools
  - Android SDK Build Tools (version specified in gradle)
  - Android SDK Platform (API level specified in gradle)
  - Android NDK (if building native code)

Your Android SDK directory should contain:

```text
android-sdk/
├── build-tools/
├── cmdline-tools/
├── licenses/
├── ndk/
├── platform-tools/
├── platforms/
└── tools/
```

- Create `local.properties` file inside `./common` directory that locates the Android SDK installation directory

Sample `local.properties` on Windows:
```properties
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
```

Sample `local.properties` on Unix-like command-line:
```properties
sdk.dir=/usr/lib/android-sdk
```

Optionally, set `godot.dir` to use a Godot source tree at a custom location instead of the default `ios/godot/`:
```properties
godot.dir=/path/to/your/shared/godot
```

### iOS Development (macOS only)
- **Xcode** - Latest stable version recommended
- **Xcode Command Line Tools** - Install via: `xcode-select --install`
- **SCons** - Install via: `pip3 install scons` or `brew install scons`
- **Python 3** - Required for SCons

### Verifying Prerequisites

```bash
# Check Java version
java -version

# macOS/iOS only
xcodebuild -version
scons --version
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Configuration

The build files are largely static and shared across all GMP plugins. Any plugin-specific build customization is handled through the following configuration files:

```text
.
├── addon/
│   └── ?.gradle.kts                   # Any extra Gradle configuration (configured in
│                                      # common/config/config.properties) for the plugin goes here
│
├── common/
│   ├── config/
│   │   └── config.properties          # Common plugin configuration
│   │
│   └── gradle/
│       └── libs.versions.toml         # Android dependencies and versions
│
└── ios/
    └── config/
        └── config.properties          # iOS configuration
```

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Common Configuration

The `common/config/config.properties` file contains core plugin settings:

```properties
# Plugin identification
pluginNodeName=...                # Name of the plugin node in Godot
pluginModuleName=...              # Module name for native code
pluginVersion=1.0                 # Plugin version

# Godot configuration
godotVersion=4.6                  # Target Godot version
godotReleaseType=stable           # Release type: stable, dev6, beta3, rc1, etc.

# Extra properties configured in the following format
extra.anotherProperty=property value

# Extra gradle configuration files in the following format
gradle.another=another.gradle.kts
```

**Key Properties:**
- `pluginNodeName` - The name of the main plugin node used in Godot
- `pluginVersion` - Semantic version for releases
- `godotVersion` - Must match your target Godot version
- `godotReleaseType` - Determines which Godot binary to download

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Mediation Configuration

The `common/config/mediation.properties` file defines ad mediation adapters:

```properties
# Example mediation adapter configuration
applovin.dependencies=com.google.ads.mediation:applovin:13.4.0.1
applovin.mavenRepo=
applovin.spmPackage=googleads/swift-package-manager-google-mobile-ads/GoogleMobileAdsMediationAppLovin
applovin.spmVersion=13.4.0.0
applovin.skAdNetworkIds=...
```

Each adapter has:
- `dependencies` - Android Maven dependencies
- `mavenRepo` - Custom Maven repository URL (if needed)
- `spmPackage` - iOS Swift Package Manager repository path
- `spmVersion` - iOS SPM package version
- `skAdNetworkIds` - iOS SKAdNetwork identifiers

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Gradle Configuration

The `common/gradle/libs.versions.toml` defines dependency versions:

```toml
[versions]
android-plugin = "8.5.0"
kotlin = "1.9.0"
...

[libraries]
...

[plugins]
android-library = { id = "com.android.library", version.ref = "android-plugin" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
```

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Local Configuration

Create `common/local.properties` to configure machine-specific paths. This file is gitignored and must be created locally.

#### Android SDK Location

```properties
# Windows
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk

# macOS/Linux
sdk.dir=/Users/YourUsername/Library/Android/sdk

# Linux (alternate)
sdk.dir=/usr/lib/android-sdk
```

#### Godot Directory (iOS — optional)

By default, the iOS build scripts download and use the Godot source from `ios/godot/` inside the project. If you want to use a Godot source tree located elsewhere on your machine (e.g. to share it across multiple plugin projects), set `godot.dir` in `local.properties`:

```properties
# Use a shared Godot source directory outside the project
godot.dir=/path/to/your/shared/godot
```

When `godot.dir` is not set, the build uses the `ios/godot/` directory. The path supports `~` and environment variable expansion.

**Note:** The specified directory must contain a valid `GODOT_VERSION` file matching the `godotVersion` property in `common/config/config.properties`. If you use the `-G` option to download Godot, it will be downloaded to whichever directory is configured and the `GODOT_VERSION` file will be created automatically.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> iOS Configuration

The `ios/config/config.properties` file contains iOS-specific settings:

```properties
# iOS deployment target
platform_version=14.3

# iOS system framework dependencies
frameworks=Foundation.framework,...

# Embedded iOS external framework dependencies
embedded_frameworks=res://ios/framework/*.xcframework,...

# Linker flags
flags=-ObjC,-Wl,...

# SPM dependencies (format: https://github.com/owner/repo.git|version|PackageName)
dependencies=https://github.com/googleads/swift-package-manager-google-mobile-ads.git|12.14.0|GoogleMobileAds
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Development Workflow

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/godot-sdk-integrations/godot-admob.git
   cd godot-admob
   ```

2. **Configure Android SDK:**
   ```bash
   echo "sdk.dir=/path/to/your/android-sdk" > common/local.properties
   ```

3. **First build:**
   ```bash
   # Android only
   ./script/build.sh -a -- -b

   # iOS only (macOS) - downloads Godot automatically
   ./script/build.sh -i -- -A
   ```

### Making Changes

1. **Edit source code:**
   - Android: `android/src/main/`
   - iOS: `ios/src/`
   - GDScript templates: `addon/src/`

2. **Build and test:**
   ```bash
   # Quick Android build
   ./script/build.sh -a -- -b

   # Install to demo app
   ./script/build.sh -D

   # Run demo in Godot to test
   cd demo
   godot project.godot
   ```

3. **Iterate:**
   - Make changes
   - Rebuild with `./script/build.sh -a -- -cb` or  `./script/build.sh -i -- -cb`
   - Test in demo app
   - Repeat until tests pass

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Building

There are three main build scripts located in the `script` directory.

- `build.sh` - the main build script
- `build_android.sh` - build script for Android platform
- `build_ios.sh` - build script for iOS platform

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Cross-Platform Builds

Cross-platform builds with the `build.sh` script.

#### Build Options

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

#### Output Locations

- **GDScript code:** `addon/build/output/`
- **Debug AAR:** `android/build/outputs/aar/*-debug.aar`
- **Release AAR:** `android/build/outputs/aar/*-release.aar`
- **Built plugin:** `common/build/plugin/`
- **Release archive:** `release/PluginTemplatePlugin-*-v*.zip`

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Android Builds

#### Quick Reference

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

#### Build Options

| Option | Description |
|--------|-------------|
| `-b` | Build plugin for Android platform (debug build variant by default) |
| `-c` | Clean Android build |
| `-d` | Uninstall Android plugin from demo app |
| `-D` | Install Android plugin to demo app |
| `-h` | Display script usage information |
| `-r` | Build Android plugin with release build variant |
| `-R` | Create Android relese archive |

#### Android Studio

If using Android Studio, make sure to open the root Gradle project from the `common` directory.

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> iOS Builds

#### Quick Reference

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

#### Build Options

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

#### Build Process Explained

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

#### Output Locations

- **Godot source:** `ios/godot/` (default) or path set by `godot.dir` in `common/local.properties`
- **Build artifacts:** `ios/build/`
- **Frameworks:** `ios/build/framework/`
- **Archives:** `ios/build/lib/*.xcarchive`
- **Release archive:** `release/PluginTemplatePlugin-iOS-v*.zip`

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Testing

### Testing in Demo App

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

### Android Testing

```bash
# Build and install
./script/build.sh -caD

# Export Android build from Godot
# Install on device/emulator
adb install demo/export/android/demo.apk

# View logs
adb logcat | grep -i AdmobPlugin
```

### iOS Testing (macOS only)

```bash
# Build and install
./script/build.sh -I -D

# Open in Xcode
cd demo
open ios/demo.xcodeproj

# Build and run on simulator/device from Xcode
```

### Automated Testing

Consider adding:
- Unit tests for native code
- Integration tests for ad loading
- UI tests for demo app
- CI/CD pipeline (GitHub Actions)

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Creating Releases

### Full Multi-Platform Release

```bash
# Create all release archives
./script/build.sh -R
```

This creates:
- `release/AdmobPlugin-Android-v*.zip`
- `release/AdmobPlugin-iOS-v*.zip`
- `release/AdmobPlugin-Multi-v*.zip` (combined)

### Platform-Specific Releases

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

### Release Checklist

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

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Installation

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Installing to Demo App

```bash
# Install both platforms
./script/build.sh -D

# Uninstall
./script/build.sh -d
```

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Installing to Your Project

```bash
# Using install script
./script/install.sh -t /path/to/your/project -z /path/to/AdmobPlugin-*.zip

# Example
./script/install.sh -t ~/MyGame -z release/AdmobPlugin-Multi-v6.0.zip
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Troubleshooting

### Common Build Issues

#### Android

**Problem:** Gradle version mismatch
```bash
# Solution: Use Gradle wrapper
cd common
./gradlew --version
./gradlew clean build
```

**Problem:** Dependency resolution failures
```bash
# Solution: Clear Gradle cache
rm -rf ~/.gradle/caches/
./gradlew clean build --refresh-dependencies
```

#### iOS

**Problem:** SPM package resolution fails
```bash
# Solution: Clear SPM cache and re-resolve
./script/build_ios.sh -pP
```

**Problem:** Header generation timeout
```bash
# Solution: Increase timeout
./script/build_ios.sh -H -t 120
```

**Problem:** Xcode build fails
```bash
# Solution: Clean derived data
rm -rf ios/build/DerivedData
./script/build_ios.sh -cb
```

**Problem:** Godot version mismatch when using a custom `godot.dir`
```
# The GODOT_VERSION file in the configured directory must match
# the godotVersion property in common/config/config.properties.
# Solution: remove and re-download Godot into the configured directory
./script/build_ios.sh -gG
```

**Problem:** Build cannot find Godot headers after setting `godot.dir`
```bash
# Verify the path is set correctly in common/local.properties:
#   godot.dir=/your/custom/path
# Then re-generate headers:
./script/build_ios.sh -H
```

**Problem:** "No such module" errors
```bash
# Solution: Ensure packages are added and resolved
./script/build_ios.sh -pP
```

### Getting Help

- Check existing [GitHub Issues](https://github.com/godot-sdk-integrations/godot-admob/issues)
- Check exısting [GitHub Discussions](https://github.com/godot-sdk-integrations/godot-admob/discussions)
- Review [Godot documentation](https://docs.godotengine.org/)
- See [Google AdMob documentation](https://developers.google.com/admob)

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Contributing Guidelines

### Code Style

- **GDScript:** Follow [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- **Java:** Follow [Google Java style guide](https://google.github.io/styleguide/javaguide.html)
- **Kotlin:** Follow [Android Kotlin style guide](https://developer.android.com/kotlin/style-guide)
- **Objective-C:** Follow [Google Objective-C style guide](https://google.github.io/styleguide/objcguide.html)
- **Swift:** Follow [Swift style guide](https://www.swift.org/documentation/api-design-guidelines/)

### Commit Messages

Use conventional commits format:

```
type(scope): subject

body

footer
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
```
feat(android): add support for native ads
fix(ios): resolve banner positioning issue
docs: update installation instructions
```

### Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test on both platforms
5. Commit with descriptive messages
6. Push to your fork
7. Open a Pull Request with:
   - Clear description of changes
   - Related issue numbers
   - Testing performed
   - Screenshots (if UI changes)

### Reporting Issues

Include:
- Plugin version
- Godot version
- Platform (Android/iOS)
- Device/OS version
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Additional Resources

- [Godot Engine Documentation](https://docs.godotengine.org/)
- [Google AdMob Documentation](https://developers.google.com/admob)
- [Android Developer Documentation](https://developer.android.com/)
- [iOS Developer Documentation](https://developer.apple.com/documentation/)
- [Gradle Documentation](https://docs.gradle.org/)

---
