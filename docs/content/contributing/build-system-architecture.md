---
title: Build System Architecture
icon: fontawesome/solid/diagram-project
---

# <img src="../images/icon.png" width="24"> Build System Architecture

The build system is centred on a **convention plugin** living in `common/build-logic/`. This is an [included build](https://docs.gradle.org/current/userguide/composite_builds.html) whose compiled output is available on the classpath of every module build script that declares `plugins { id("base-conventions") }`.

### Config Data Classes

All plugin, Godot, iOS, and build settings are loaded once into typed immutable data classes. Project build scripts access them through `Project` extension functions - the same call pattern used throughout the Kotlin ecosystem:

| Extension function   | Data class    | Source file                                    |
|----------------------|---------------|------------------------------------------------|
| `loadPluginConfig()` | `PluginConfig` | `common/config/plugin.properties`             |
| `loadGodotConfig()`  | `GodotConfig`  | `common/config/godot.properties`              |
| `loadIosConfig()`    | `IosConfig`    | `ios/config/ios.properties` + `ios/config/spm_dependencies.json` |
| `loadBuildConfig()`  | `BuildConfig`  | `common/config/build.properties` + all four `*-build.properties` |

Usage in any module build script:

```kotlin
plugins { id("base-conventions") }

val pluginConfig = loadPluginConfig()
val godotConfig  = loadGodotConfig()
val iosConfig    = loadIosConfig()

println(pluginConfig.pluginName)        // "AdmobPlugin"
println(godotConfig.godotAarUrl)        // full GitHub download URL
println(iosConfig.frameworks)           // List<String> - already parsed
```

### `base-conventions` Convention Plugin

Applying `id("base-conventions")` in a module build script:

1. Loads all four config data classes.
2. Bridges every scalar config value onto `project.extra` (for compatibility with `apply(from = …)` scripts that cannot reference build-logic types directly).
3. Sets shared directory-layout extras (`pluginDir`, `repositoryRootDir`, `archiveDir`, `demoDir`).
4. Applies the per-module user-defined extra properties and extra Gradle scripts from `BuildConfig`, scoped by `project.path` - so `:android` only receives `BuildConfig.androidExtraProperties` / `androidExtraGradle`, `:ios` only receives the iOS equivalents, and so on.

### `IosConfig` List Fields

The `frameworks`, `embeddedFrameworks`, and `linkerFlags` fields on `IosConfig` are `List<String>`. The comma-separated values in `ios/config/ios.properties` are split and trimmed at load time, so consumers never need to parse delimiters:

```kotlin
val iosConfig = loadIosConfig()
iosConfig.frameworks         // ["Foundation.framework", "Network.framework"]
iosConfig.embeddedFrameworks // [] when empty
iosConfig.linkerFlags        // ["-ObjC"]
```

### `IosConfig` SPM Dependencies

`IosConfig` also exposes a `spmDependencies: List<SpmDependency>` field, decoded at load time from `ios/config/spm_dependencies.json`. Each `SpmDependency` entry carries three fields:

| Field      | Type           | Description                                      |
|------------|----------------|--------------------------------------------------|
| `url`      | `String`       | Git repository URL of the Swift package          |
| `version`  | `String`       | Minimum version requirement                      |
| `products` | `List<String>` | SPM product names to link against                |

```kotlin
val iosConfig = loadIosConfig()
iosConfig.spmDependencies   // [SpmDependency(url="https://...", version="1.2.3", products=["ProductA"])]
```

`base-conventions` bridges this list onto `project.extra["iosSpmDependencies"]` so it is accessible from any task lambda that cannot reference `IosConfig` by type directly.

The `addon-build.gradle.kts` `generateGDScript` and `generateSharedGDScript` tasks expose the list via the `@spmDependencies@` token. Each dependency is rendered as a GDScript dictionary literal using [StringName](https://docs.godotengine.org/en/stable/classes/class_stringname.html) key syntax (`&"key"`), and multiple entries are joined with `, ` — without outer brackets, because they are supplied by the surrounding GDScript constant:

```gdscript
# Template source:
const SPM_DEPENDENCIES: Array = [ @spmDependencies@ ]

# After token replacement (two dependencies):
const SPM_DEPENDENCIES: Array = [ {&"url": "https://github.com/owner/repo", &"version": "1.2.3", &"products": ["ProductA", "ProductB"]}, {&"url": "https://github.com/other/pkg", &"version": "2.0.0", &"products": ["ProductC"]} ]
```
