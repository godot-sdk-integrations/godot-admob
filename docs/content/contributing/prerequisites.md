---
title: Prerequisites
icon: fontawesome/solid/list-check
---

# <img src="../images/icon.png" width="24"> Prerequisites

## General Requirements
- **Git** - For version control
- **Bash** - For running build scripts (macOS/Linux native, Windows via WSL or Git Bash)

## Android Development
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

## iOS Development (macOS only)
- **Xcode** - Latest stable version recommended
- **Xcode Command Line Tools** - Install via: `xcode-select --install`
- **Ruby** - Required for SPM dependency management via `spm_manager.rb` (macOS system Ruby is sufficient)
- **xcodeproj gem** - Installed automatically by the build system if missing, or manually via: `gem install xcodeproj --user-install`

## Developer Tools (Optional - required for format checking)

These tools are needed when running `checkFormat` or `applyFormat` tasks:

- **ktlint** - Kotlin/KTS formatter: `brew install ktlint`
- **shellcheck** - Shell script linter: `brew install shellcheck`
- **editorconfig-checker** - EditorConfig compliance: `brew install editorconfig-checker`
- **clang-format** - ObjC/C++ formatter: `brew install clang-format` (iOS only)
- **swiftlint** - Swift linter/formatter: `brew install swiftlint` (iOS only)
- **gdformat** - GDScript formatter: install via the Godot toolchain

## Verifying Prerequisites

```bash
# Check Java version
java -version

# macOS/iOS only
xcodebuild -version
ruby --version
gem list xcodeproj
```
