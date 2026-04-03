---
title: Configuration
icon: fontawesome/solid/sliders
---

# <img src="../images/icon.png" width="24"> Configuration

The build files are static and shared across all GMP plugins. Any plugin-specific build customization is handled through the following configuration files:

```text
.
├── addon/
│   ├── ?.gradle.kts                       # Any extra addon-specific Gradle configuration (configured in
│   │                                      # addon/config/addon-build.properties) for the plugin goes here
│   └── config/
│       └── addon-build.properties         # Gradle build customization for addon module
│
├── android/
│   ├── android-build.gradle.kts           # Android build configuration
│   ├── ?.gradle.kts                       # Any extra Android-specific Gradle configuration (configured in
│   │                                      # android/config/android-build.properties) for the plugin goes here
│   └── config/
│       └── android-build.properties       # Gradle build customization for android module
│
├── common/
│   ├── config/
│   │   ├── build.properties               # Build-related property configuration & customization
│   │   ├── godot.properties               # Godot version configuration
│   │   └── plugin.properties              # Plugin configuration
│   │
│   └── gradle/
│       └── libs.versions.toml             # Android dependencies and versions
│
└── ios/
    └── config/
        ├── ios.properties                 # iOS configuration
        ├── ios-build.properties           # Gradle build customization for ios module
        └── spm_dependencies.json          # SPM dependency configuration
```

## <img src="../images/icon.png" width="20"> Common Configuration

The `common/config/plugin.properties` file contains core plugin settings:

```properties
# Plugin identification
pluginNodeName=...                # Name of the plugin node in Godot (e.g. MyPlugin)
pluginModuleName=...              # Snake-case module name for native symbols (e.g. my_plugin)
pluginPackage=...                 # Fully-qualified Java/Kotlin package (e.g. org.godotengine.plugin.myplugin)
pluginVersion=1.0                 # Plugin version
```

The `common/config/godot.properties` file contains core Godot version settings:

```properties
# Godot configuration
godotVersion=4.6                  # Target Godot version
godotReleaseType=stable           # Release type: stable, dev6, beta3, rc1, etc.
```

The `common/config/build.properties` file contains Gradle build-related property settings. The `gradleProjectName` key is required. Extra properties and Gradle scripts that apply only to the **root project** use a `root.` prefix:

```properties
gradleProjectName=godot-*-plugin

# Extra properties set on the root project only
root.extra.anotherProperty=property value

# Extra Gradle scripts applied to the root project only
root.gradle.another=another.gradle.kts
```

Per-module extra properties and scripts are configured in each module's own `*-build.properties` file (see [Build Customization](#-build-customization) below).

**Key Properties:**
- `pluginNodeName` - The name of the main plugin node used in Godot
- `pluginVersion` - Semantic version for releases
- `godotVersion` - Must match your target Godot version
- `godotReleaseType` - Determines which Godot binary to download

## <img src="../images/icon.png" width="20"> Build Customization

Plugin-specific build customizations can be configured in the following files.

`common/config/build.properties` for root-project customizations. The `root.` prefix scopes each entry to the root project only:

```properties
# Set plugin-specific extra properties on the root project
#root.extra.myProperty=value

# Configure plugin-specific Gradle scripts for the root project
#root.gradle.extraGradle=extra.gradle.kts
```

`addon/config/addon-build.properties` for addon-module build customizations:

```properties
# Set plugin-specific extra properties for addon module
#extra.myProperty=value

# Configure plugin-specific Gradle scripts for addon module
#gradle.extraGradle=extra.gradle.kts
```

`android/config/android-build.properties` for android-module build customizations:

```properties
# Set plugin-specific extra properties for android module
#extra.myProperty=value

# Configure plugin-specific Gradle scripts for android module
#gradle.extraGradle=extra.gradle.kts
```

`ios/config/ios-build.properties` for ios-module build customizations:

```properties
# Set plugin-specific extra properties for ios module
#extra.myProperty=value

# Configure plugin-specific Gradle scripts for ios module
#gradle.extraGradle=extra.gradle.kts
```

Each `extra.*` key sets a Gradle extra property on the corresponding module's project. Each `gradle.*` key applies the named Gradle script file to that module via `project.apply(from = …)`. Extra scripts are resolved relative to the repository root.

## <img src="../images/icon.png" width="20"> Local Configuration

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

### Godot Directory (iOS - optional)

By default, the iOS build scripts download and use the Godot source from `ios/godot/` inside the project. If you want to use a Godot source tree located elsewhere on your machine (e.g. to share it across multiple plugin projects), set `godot.dir` in `local.properties`:

```properties
# Use a shared Godot source directory outside the project
godot.dir=/path/to/your/shared/godot
```

When `godot.dir` is not set, the build uses the `ios/godot/` directory. The path supports `~` and environment variable expansion.

### Godot Android Library (AAR - optional)

By default, the Godot Android AAR libary file is expected to be placed inside `android/libs/` directory inside the project. If you want to use a location elsewhere on your machine (e.g. to share it across multiple plugin projects), set `lib.dir` in `local.properties`:

```properties
# Use a shared Godot AAR library directory outside the project
lib.dir=/path/to/your/shared/aar
```

When `lib.dir` is not set, the build uses the `android/libs/` directory. The path supports `~` and environment variable expansion.

!!! note
  The Godot headers directory must contain a `GODOT_VERSION` file whose content matches the `godotVersion` property in `common/config/godot.properties`. The `downloadGodotHeaders` Gradle task creates this file automatically when it downloads the headers. If the directory already exists but contains a different version, the build will fail with a clear error message - run `./script/build_ios.sh -gG` to remove the old directory and re-download the correct version.

## <img src="../images/icon.png" width="20"> iOS Configuration

The `ios/config/ios.properties` file contains iOS-specific settings:

```properties
# iOS deployment target
platform_version=14.3

# Swift language version (required - must match your Xcode project)
swift_version=5.9

# iOS system framework dependencies (comma-separated)
frameworks=Foundation.framework,...

# Embedded iOS external framework dependencies (comma-separated; may be empty)
# Use this for vendored or prebuilt xcframeworks that are NOT managed by SPM.
# SPM packages should be declared in spm_dependencies.json instead.
embedded_frameworks=res://ios/framework/*.xcframework,...

# Linker flags (comma-separated; may be empty)
flags=-ObjC,-Wl,...
```

The `frameworks`, `embedded_frameworks`, and `flags` values are comma-separated lists. The build system parses them into typed lists at configuration time (`IosConfig.kt`) - blank entries are ignored. Values are used as-is for token replacement in GDScript templates and passed directly to `xcodebuild`.

GDScript templates may reference the following tokens for iOS values set in `ios.properties` and `spm_dependencies.json`:

| Token                    | Source                        | GDScript type  |
|--------------------------|-------------------------------|----------------|
| `@iosFrameworks@`        | `frameworks` (ios.properties) | quoted strings |
| `@iosEmbeddedFrameworks@`| `embedded_frameworks`         | quoted strings |
| `@iosLinkerFlags@`       | `flags`                       | quoted strings |
| `@spmDependencies@`      | `spm_dependencies.json`       | GDScript dicts |

The `@spmDependencies@` token produces GDScript dictionary literals with StringName keys and no outer brackets (see [`IosConfig` SPM Dependencies](#iosconfig-spm-dependencies) for the exact format).

SPM dependencies are configured in the `ios/config/spm_dependencies.json` file in the following format:

```json
[
  {
    "url": "https://github.com/Alamofire/Alamofire",
    "version": "5.8.1",
    "products": [
      "Alamofire",
      "AlamofireImage"
    ]
  },
  {
    "url": "https://github.com/kishikawakatsumi/KeychainAccess",
    "version": "4.2.2",
    "products": [
      "KeychainAccess"
    ]
  }
]
```

If the plugin has no SPM dependencies:

```json
[

]
```
