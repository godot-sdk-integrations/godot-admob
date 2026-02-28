---
title: Project structure
---

# <img src="../images/icon.png" width="28"> Contributing

Thank you for your interest in contributing to the Godot AdMob Plugin! This guide will help you understand the project structure, build processes, and development workflows.

## <img src="../images/icon.png" width="24"> Project structure

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