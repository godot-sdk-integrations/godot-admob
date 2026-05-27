//
// © 2026-present https://github.com/cengiz-pz
//

import java.io.File
import kotlinx.serialization.json.Json
import org.gradle.api.Project

// -- Config loaders ------------------------------------------------------------
//
// These Project extension functions are the public API for loading config data
// classes in any project build script that applies id("base-conventions").
//
// Because they are defined in build-logic/src/main/kotlin/ they are on the
// compilation classpath of every project build script that applies a build-logic
// plugin.  The implicit receiver in a build script is the Project, so they are
// callable without qualification:
//
//   plugins { id("base-conventions") }
//
//   val pluginConfig = loadPluginConfig()
//   val godotConfig  = loadGodotConfig()
//   val iosConfig    = loadIosConfig()
//   val buildConfig  = loadBuildConfig()
//
//   // Member access - identical to how SpmDependency.url / .version / .products work
//   println(pluginConfig.pluginName)
//   println(godotConfig.godotAarUrl)
//   println(iosConfig.swiftVersion)
//   println(buildConfig.androidExtraProperties)

/**
 * Loads [PluginConfig] from `gradle/config/plugin.properties`.
 */
fun Project.loadPluginConfig(): PluginConfig =
    PluginConfig.load(rootProject.rootDir)

/**
 * Loads [GodotConfig] from `gradle/config/godot.properties`.
 */
fun Project.loadGodotConfig(): GodotConfig =
    GodotConfig.load(rootProject.rootDir)

/**
 * Loads [IosConfig] from `ios/config/ios.properties` at the repository root.
 *
 * The repository root is resolved as `rootProject.rootDir.parentFile` (i.e. one
 * level above the `gradle/` project directory).
 */
fun Project.loadIosConfig(): IosConfig =
    IosConfig.load(rootProject.rootDir)

/**
 * Loads [BuildConfig] from all four per-module properties files:
 * `gradle/config/build.properties`, `addon/config/addon-build.properties`,
 * `android/config/android-build.properties`, and `ios/config/ios-build.properties`.
 */
fun Project.loadBuildConfig(): BuildConfig =
    BuildConfig.load(rootProject.rootDir)

// -- SPM helpers ---------------------------------------------------------------

/**
 * Reads SPM dependency entries from an `spm_dependencies.json` config file.
 *
 * Returns a list of [SpmDependency] objects decoded via kotlinx.serialization,
 * or an empty list when [configFile] does not exist.
 *
 * Usage (replaces the old project.extra cast pattern):
 *   val deps = readSpmDependencies(file("$projectDir/config/spm_dependencies.json"))
 */
fun Project.readSpmDependencies(configFile: File): List<SpmDependency> {
    if (!configFile.exists()) return emptyList()
    return Json.decodeFromString<List<SpmDependency>>(configFile.readText())
}

// -- BuildConfig convenience helper -------------------------------------------

/**
 * Forwards all entries from [extraProperties] into this project's extra-properties
 * extension, and applies every file path in [extraGradle] as a Gradle script on
 * this project.
 *
 * Paths in [extraGradle] are resolved relative to the project directory unless
 * they are absolute.
 */
fun Project.applyBuildConfigExtras(
    extraProperties: Map<String, String>,
    extraGradle: Map<String, String>,
) {
    extraProperties.forEach { (name, value) ->
        extensions.extraProperties.set(name, value)
        println("[CONFIG] Set extra property: $name = $value")
    }
    extraGradle.forEach { (label, path) ->
        val resolved = if (path.startsWith("/")) path else "./$path"
        apply(mapOf("from" to resolved))
        println("[CONFIG] Applied extra script: $path (from BuildConfig key $label)")
    }
}
