# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="28"> Contributing

Thank you for your interest in contributing to the Godot AdMob Plugin! This guide will help you understand the project structure, build processes, and development workflows.

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Table of Contents

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

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Project structure

```text
.
├── addon/                              # GDScript addon module
│   ├── build.gradle.kts               # Gradle build configuration
│   ├── config.gradle.kts              # Gradle configuration
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
│   ├── settings.gradle.kts            # Gradle settings
│   ├── build/
│   │   ├── archive/                   # Generated archives
│   │   ├── plugin/                    # Built plugin files
│   │   └── reports/                   # Build reports
│   ├── config/
│   │   ├── config.properties          # Common plugin configuration
│   │   └── mediation.properties       # Ad mediation configuration
│   └── gradle/                        # Gradle wrapper and version catalogs
│       └── libs.versions.toml         # Dependency versions
│
├── demo/                               # Demo application
│   ├── addons/                        # Installed plugin files
│   ├── ios/                           # iOS-specific demo files
│   └── *.gd                           # Demo app scripts
│
├── ios/                                # iOS platform module
│   ├── admob/                         # iOS platform code
│   ├── admob_plugin.xcodeproj/        # Xcode project
│   ├── build/                         # iOS build outputs
│   ├── config/
│   │   ├── config.properties          # iOS configuration
│   │   └── *.gdip                     # Godot iOS plugin config
│   ├── godot/                         # Downloaded Godot source
│   └── Pods/                          # CocoaPods dependencies
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

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Prerequisites

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

Sample `localtion.properties` on Windows:
```properties
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk
```

Sample `localtion.properties` on Unix-like command-line:
```properties
sdk.dir=/usr/lib/android-sdk
```

### iOS Development (macOS only)
- **Xcode** - Latest stable version recommended
- **Xcode Command Line Tools** - Install via: `xcode-select --install`
- **CocoaPods** - Install via: `sudo gem install cocoapods`
- **SCons** - Install via: `pip3 install scons` or `brew install scons`
- **Python 3** - Required for SCons

### Verifying Prerequisites

```bash
# Check Java version
java -version

# macOS/iOS only
xcodebuild -version
pod --version
scons --version
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Configuration

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Common Configuration

The `common/config/config.properties` file contains core plugin settings:

```properties
# Plugin identification
pluginNodeName=...                # Name of the plugin node in Godot
pluginModuleName=...              # Module name for native code
pluginVersion=1.0                 # Plugin version

# Godot configuration
godotVersion=4.5.1                 # Target Godot version
godotReleaseType=stable            # Release type: stable, dev6, beta3, rc1, etc.

# Extra properties configured in the following format
extra.anotherProperty=...

# Extra configuration files in the following format
gradle.another=another.gradle.kts
```

**Key Properties:**
- `pluginNodeName` - The name of the main plugin node used in Godot
- `pluginVersion` - Semantic version for releases
- `godotVersion` - Must match your target Godot version
- `godotReleaseType` - Determines which Godot binary to download

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Mediation Configuration

The `common/config/mediation.properties` file defines ad mediation adapters:

```properties
# Example mediation adapter configuration
applovin.dependencies=com.google.ads.mediation:applovin:13.4.0.1
applovin.mavenRepo=
applovin.pod=GoogleMobileAdsMediationAppLovin
applovin.podVersion=13.4.0.0
applovin.skAdNetworkIds=...
```

Each adapter has:
- `dependencies` - Android Maven dependencies
- `mavenRepo` - Custom Maven repository URL (if needed)
- `pod` - iOS CocoaPod name
- `podVersion` - iOS CocoaPod version
- `skAdNetworkIds` - iOS SKAdNetwork identifiers

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Gradle Configuration

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

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Android SDK Configuration

Create `common/local.properties` to specify your Android SDK location:

```properties
# Windows
sdk.dir=C\:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk

# macOS/Linux
sdk.dir=/Users/YourUsername/Library/Android/sdk

# Linux (alternate)
sdk.dir=/usr/lib/android-sdk
```

**Note:** This file is gitignored and must be created locally.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Configuration

The `ios/config/config.properties` file contains iOS-specific settings:

```properties
# iOS deployment target
platform_version=14.3

# iOS system framework dependencies
frameworks=Foundation.framework,...

# EmbeddedniOS external framework dependencies
embedded_frameworks=res://ios/framework/*.xcframework,...

# Linker flags
flags=-ObjC,-Wl,...

# Pod dependencies
dependencies=Dependency-SDK:1.0.0
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Development Workflow

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

3. **First build (downloads Godot automatically):**
   ```bash
   # Android only
   ./script/build.sh -ca

   # iOS only (macOS)
   ./script/build.sh -i -- -A

   # Both platforms
   ./script/build.sh -ca -i -- -A
   ```

### Making Changes

1. **Edit source code:**
   - Android: `android/src/main/`
   - iOS: `ios/admob/`
   - GDScript templates: `addon/src/`

2. **Build and test:**
   ```bash
   # Quick Android build
   ./script/build.sh -a

   # Install to demo app
   ./script/build.sh -D

   # Run demo in Godot to test
   cd demo
   godot project.godot
   ```

3. **Iterate:**
   - Make changes
   - Rebuild with `./script/build.sh -a`
   - Test in demo app
   - Repeat until satisfied

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Building

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Android Builds

#### Quick Reference

```bash
# Clean and build debug
./script/build.sh -ca

# Clean and build release
./script/build.sh -car

# Create release archive
./script/build.sh -carz

# Build specific Gradle task
./script/run_gradle_task.sh buildDebug
./script/run_gradle_task.sh buildRelease
./script/run_gradle_task.sh createArchive
```

#### Build Options

| Option | Description |
|--------|-------------|
| `-a` | Build plugin for Android platform |
| `-A` | Build and create Android release archive |
| `-c` | Remove existing Android build |
| `-r` | Use release build variant |
| `-z` | Create Android zip archive |

#### Available Gradle Tasks

```bash
# Generate GDScript code only
./script/run_gradle_task.sh generateGDScript

# Copy assets
./script/run_gradle_task.sh copyAssets

# Build debug AAR
./script/run_gradle_task.sh buildDebug

# Build release AAR
./script/run_gradle_task.sh buildRelease

# Build both debug and release
./script/run_gradle_task.sh build

# Create release archive
./script/run_gradle_task.sh createArchive

# Install to demo app
./script/run_gradle_task.sh installToDemo

# Clean build
./script/run_gradle_task.sh clean
```

#### Output Locations

- **GDScript code:** `addon/build/output/`
- **Debug AAR:** `android/build/outputs/aar/*-debug.aar`
- **Release AAR:** `android/build/outputs/aar/*-release.aar`
- **Built plugin:** `common/build/plugin/`
- **Release archive:** `common/build/archive/AdmobPlugin-Android-v*.zip`

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Builds

#### Quick Reference

```bash
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
| `-a` | Generate headers, install pods, and build |
| `-A` | Download Godot + full build |
| `-b` | Build plugin only |
| `-c` | Clean existing build |
| `-g` | Remove Godot directory |
| `-G` | Download Godot |
| `-h` | Display help |
| `-H` | Generate Godot headers |
| `-p` | Remove pods and pod trunk |
| `-P` | Install CocoaPods |
| `-t <seconds>` | Set header generation timeout |
| `-z` | Create zip archive |

#### Build Process Explained

The iOS build process involves several steps:

1. **Download Godot** (if needed):
   - Downloads the official Godot binary from GitHub
   - Version specified in `config.properties`
   - Extracted to `ios/godot/`

2. **Generate Headers**:
   - Starts a Godot build to generate C++ headers
   - Timeout prevents full Godot build (we only need headers)
   - Default timeout: 40 seconds (increase if needed)

3. **Install CocoaPods**:
   - Downloads ad network SDKs
   - Installs mediation adapters
   - Creates workspace for Xcode

4. **Build XCFrameworks**:
   - Builds for iOS device (arm64)
   - Builds for iOS simulator (arm64, x86_64)
   - Creates universal XCFrameworks for debug and release

#### Output Locations

- **Godot source:** `ios/godot/`
- **Build artifacts:** `ios/build/`
- **Frameworks:** `ios/build/framework/`
- **Archives:** `ios/build/lib/*.xcarchive`
- **Release archive:** `ios/build/release/AdmobPlugin-iOS-v*.zip`

#### Common iOS Build Patterns

```bash
# Initial setup
./script/build_ios.sh -A

# Development cycle (reuses Godot and pods)
./script/build_ios.sh -cb

# Update dependencies
./script/build_ios.sh -pP

# Clean slate rebuild
./script/build_ios.sh -cgpA

# Create release with custom header timeout
./script/build_ios.sh -cH -t 60 -Pbz
```

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Cross-Platform Builds

Use the main `build.sh` script for coordinated builds:

```bash
# Build Android, then iOS
./script/build.sh -cai -- -ca

# iOS build with options (passed after --)
./script/build.sh -i -- -cgA

# Clean everything
./script/build.sh -C

# Full release (creates all archives)
./script/build.sh -R
```

**Note:** Options after `--` are passed to `build_ios.sh`

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Testing

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
adb logcat | grep -i admob
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

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Creating Releases

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
# Android only
./script/build.sh -A

# iOS only (assumes Godot already downloaded)
./script/build.sh -I

# Multi-platform (combines existing archives)
./script/build.sh -Z
```

### Release Checklist

- [ ] Update version in `common/config/config.properties`
- [ ] Test on both platforms
- [ ] Build release archives
- [ ] Create GitHub release
- [ ] Upload archives to release & publish
- [ ] Close GitHub milestone
- [ ] Post GitHub announcement
- [ ] Update Asset Library listing
- [ ] Update Asset Store listing

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Installation

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Installing to Demo App

```bash
# Install both platforms
./script/build.sh -D

# Uninstall
./script/build.sh -d
```

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Installing to Your Project

```bash
# Using install script
./script/install.sh -t /path/to/your/project -z /path/to/AdmobPlugin-*.zip

# Example
./script/install.sh -t ~/MyGame -z release/AdmobPlugin-Multi-v6.0.zip
```

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Troubleshooting

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

**Problem:** CocoaPods installation fails
```bash
# Solution: Update CocoaPods
sudo gem install cocoapods
pod repo update
cd ios
pod install --repo-update
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

**Problem:** "No such module" errors
```bash
# Solution: Ensure pods are installed
./script/build_ios.sh -pP
```

### Getting Help

- Check existing [GitHub Issues](https://github.com/godot-sdk-integrations/godot-admob/issues)
- Check exısting [GitHub Discussions](https://github.com/godot-sdk-integrations/godot-admob/discussions)
- Review [Godot documentation](https://docs.godotengine.org/)
- See [Google AdMob documentation](https://developers.google.com/admob)

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Contributing Guidelines

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

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Additional Resources

- [Godot Engine Documentation](https://docs.godotengine.org/)
- [Google AdMob Documentation](https://developers.google.com/admob)
- [Android Developer Documentation](https://developer.android.com/)
- [iOS Developer Documentation](https://developer.apple.com/documentation/)
- [Gradle Documentation](https://docs.gradle.org/)

---
