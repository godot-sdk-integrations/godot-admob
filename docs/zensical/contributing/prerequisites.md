---
title: Prerequisites
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
- **SCons** - Install via: `pip3 install scons` or `brew install scons`
- **Python 3** - Required for SCons

## Verifying Prerequisites

```bash
# Check Java version
java -version

# macOS/iOS only
xcodebuild -version
scons --version
```