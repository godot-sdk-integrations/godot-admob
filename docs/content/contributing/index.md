---
title: Overview
icon: fontawesome/solid/info
---

# <img src="../images/icon.png" width="28"> Contributing

Thank you for your interest in contributing to the Godot AdMob Plugin! This guide will help you understand the project structure, build processes, and development workflows.

## <img src="../images/icon.png" width="24"> Project structure

```text
.
├── addon/                               # GDScript addon module
│   ├── build.gradle.kts                   # Gradle build configuration
│   ├── config.gradle.kts                  # Gradle configuration
│   ├── ?.gradle.kts                       # Any extra Gradle configuration (configured in
│   │                                      # common/config/config.properties) for the plugin goes here
│   ├── build/
│   │   └── output/                        # Generated GDScript code
│   │
│   ├── config/
│   │   └── addon.gradle.kts               # Gradle configuration for addon module
│   │
│   └── src/                               # GDScript templates
│
├── android/                             # Android platform module
│   ├── build.gradle.kts                   # Android build configuration
│   │
│   ├── build/
│   │   └── outputs/                       # Generated Android AAR files
│   │
│   ├── config/
│   │   └── android.gradle.kts             # Gradle configuration for android module
│   │
│   ├── libs/                              # Godot library for Android (default location; configurable via local.properties)
│   └── src/main/                          # Android source code
│
├── common/                              # Shared build configuration
│   ├── build.gradle.kts                   # Root build configuration
│   │
│   ├── gradle.properties                  # Gradle properties
│   ├── local.properties                   # Local machine config (gitignored)
│   ├── settings.gradle.kts                # Gradle settings
│   ├── build/
│   │   ├── archive/                       # Generated archives
│   │   ├── plugin/                        # Built plugin files
│   │   └── reports/                       # Build reports
│   │
│   ├── config/
│   │   ├── common.gradle.kts              # Common Gradle configuration
│   │   └── config.properties              # Common plugin configuration
│   │
│   └── gradle/                            # Gradle wrapper and version catalogs
│       └── libs.versions.toml             # Dependencies and versions
│
├── demo/                                # Demo application
│   ├── addons/                            # Installed plugin files
│   ├── ios/                               # iOS-specific demo files
│   └── *.gd                               # Demo app scripts
│
├── ios/                                 # iOS platform module
│   ├── src/                               # iOS platform code
│   ├── plugin.xcodeproj/                  # Xcode project
│   ├── build/                             # iOS build outputs
│   │
│   ├── config/
│   │   ├── config.properties              # iOS configuration
│   │   ├── ios.gradle.kts                 # iOS Gradle configuration
│   │   ├── spm_dependencies.json          # SPM dependency configuration
│   │   └── *.gdip                         # Godot iOS plugin config
│   │
│   └── godot/                             # Downloaded Godot source (default location; configurable via local.properties)
│
├── script/                              # Build and utility scripts
│   ├── build.sh                           # Main build script
│   ├── build_android.sh                   # Android build script
│   ├── build_ios.sh                       # iOS build script
│   ├── install.sh                         # Plugin installation script
│   ├── run_gradle_task.sh                 # Gradle task runner
│   └── get_config_property.sh             # Configuration reader
│
├── docs/                                # Documentation
│
└── release/                             # Final release archives
```
