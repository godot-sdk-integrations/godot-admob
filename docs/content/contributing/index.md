---
title: Overview
icon: fontawesome/solid/info
---

# <img src="../images/icon.png" width="28"> Contributing

Thank you for your interest in contributing to the Godot AdMob Plugin! This guide will help you understand the project structure, build processes, and development workflows.

## <img src="../images/icon.png" width="24"> Project structure

```text
.
├-- addon/                               # GDScript interface module
│   ├-- addon-build.gradle.kts             # Gradle build configuration for addon module
│   ├-- ?.gradle.kts                       # Any extra addon-specific Gradle configuration (configured in
│   │                                      # addon/config/addon-build.properties) for the plugin goes here
│   ├-- build/
│   │   └-- output/                        # Generated GDScript code
│   │
│   ├-- config/
│   │   └-- addon-build.properties         # Gradle build customization for addon module
│   │
│   └-- src/
│       ├-- main                           # Main GDScript templates
│       └-- shared                         # GDScript templates in common with other plugins, if any
│
├-- android/                             # Android platform module
│   ├-- android-build.gradle.kts           # Android build configuration
│   ├-- ?.gradle.kts                       # Any extra Android-specific Gradle configuration (configured in
│   │                                      # android/config/android-build.properties) for the plugin goes here
│   │
│   ├-- build/
│   │   └-- outputs/                       # Generated Android AAR files
│   │
│   ├-- config/
│   │   └-- android-build.properties       # Gradle build customization for android module
│   │
│   ├-- libs/                              # Godot library for Android (default location; configurable via local.properties)
│   └-- src/main/                          # Android source code
│
├-- common/                              # Gradle root - shared build configuration
│   ├-- build.gradle.kts                   # Root build configuration
│   ├-- ?.gradle.kts                       # Any extra Gradle configuration (configured in
│   │                                      # common/config/build.properties) for the plugin goes here
│   │
│   ├-- gradle.properties                  # Gradle properties
│   ├-- local.properties                   # Local machine config (gitignored)
│   ├-- settings.gradle.kts                # Gradle settings
│   ├-- build/
│   │   ├-- archive/                       # Generated archives
│   │   ├-- plugin/                        # Built plugin files
│   │   └-- reports/                       # Build reports
│   │
│   ├-- build-logic/                       # Convention plugin (precompiled script plugins)
│   │   ├-- build.gradle.kts
│   │   ├-- settings.gradle.kts
│   │   └-- src/main/kotlin/
│   │       ├-- base-conventions.gradle.kts  # Core convention plugin - applied by every module
│   │       ├-- BuildConfig.kt               # Reads build.properties + per-module *-build.properties
│   │       ├-- GodotConfig.kt               # Reads godot.properties
│   │       ├-- IosConfig.kt                 # Reads ios/config/ios.properties
│   │       ├-- PluginConfig.kt              # Reads plugin.properties
│   │       ├-- ProjectExtensions.kt         # loadPluginConfig(), loadGodotConfig(), loadIosConfig(), loadBuildConfig()
│   │       └-- SpmDependency.kt             # Data class for spm_dependencies.json entries
│   │
│   ├-- config/
│   │   ├-- build.properties               # Build-related property configuration & customization
│   │   ├-- godot.properties               # Godot version configuration
│   │   └-- plugin.properties              # Plugin configuration
│   │
│   └-- gradle/                            # Gradle wrapper and version catalogs
│       └-- libs.versions.toml             # Dependencies and versions
│
├-- demo/                                # Demo application
│   ├-- addons/                            # Installed plugin files
│   ├-- ios/                               # iOS-specific demo files
│   └-- *.gd                               # Demo app scripts
│
├-- ios/                                 # iOS platform module
│   ├-- ios-build.gradle.kts               # iOS build configuration
│   ├-- ?.gradle.kts                       # Any extra iOS-specific Gradle configuration (configured in
│   │                                      # ios/config/ios-build.properties) for the plugin goes here
│   │
│   ├-- src/                               # iOS platform code
│   ├-- plugin.xcodeproj/                  # Xcode project
│   ├-- build/                             # iOS build outputs
│   │
│   ├-- config/
│   │   ├-- ios.properties                 # iOS configuration
│   │   ├-- ios-build.properties           # Gradle build customization for ios module
│   │   ├-- spm_dependencies.json          # SPM dependency configuration
│   │   └-- *.gdip                         # Godot iOS plugin config
│   │
│   └-- godot/                             # Downloaded Godot source (default location; configurable via local.properties)
│
├-- script/                              # Build and utility scripts
│   ├-- build.sh                           # Main build script
│   ├-- build_android.sh                   # Android build script
│   ├-- build_ios.sh                       # iOS build script
│   ├-- install.sh                         # Plugin installation script
│   ├-- run_gradle_task.sh                 # Gradle task runner
│   ├-- get_config_property.sh             # Configuration reader
│   └-- spm_manager.rb                     # Ruby script for managing SPM dependencies in Xcode project
│
├-- docs/                                # Documentation
│
└-- release/                             # Final release archives
```
