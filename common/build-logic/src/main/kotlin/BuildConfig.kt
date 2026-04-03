//
// © 2026-present https://github.com/cengiz-pz
//

import java.io.File
import java.util.Properties

/**
 * Immutable value object holding build-wide settings and per-module extension points,
 * loaded from four properties files.
 *
 * Obtain an instance via [Project.loadBuildConfig] (defined in `ProjectExtensions.kt`),
 * which is available in any project build script that applies `id("base-conventions")`:
 *
 * ```kotlin
 * plugins { id("base-conventions") }
 *
 * val buildConfig = loadBuildConfig()
 * println(buildConfig.gradleProjectName)           // "my-plugin"
 * println(buildConfig.androidExtraProperties)      // Map<String, String>
 * ```
 *
 * ## Source files
 *
 * | Property group           | File (relative to repo root)                  |
 * |--------------------------|-----------------------------------------------|
 * | [gradleProjectName]      | `gradle/config/build.properties`              |
 * | [rootExtraProperties]    | `gradle/config/build.properties`              |
 * | [rootExtraGradle]        | `gradle/config/build.properties`              |
 * | [addonExtraProperties]   | `addon/config/addon-build.properties`         |
 * | [addonExtraGradle]       | `addon/config/addon-build.properties`         |
 * | [androidExtraProperties] | `android/config/android-build.properties`     |
 * | [androidExtraGradle]     | `android/config/android-build.properties`     |
 * | [iosExtraProperties]     | `ios/config/ios-build.properties`             |
 * | [iosExtraGradle]         | `ios/config/ios-build.properties`             |
 *
 * ## Key conventions in per-module files
 *
 * ```properties
 * # Forwarded to project.extra["myFlag"] in that module
 * extra.myFlag=true
 *
 * # Applied via project.apply(from = …) in that module
 * gradle.myExtras=config/my-extras.gradle.kts
 * ```
 */
data class BuildConfig(
    /** Gradle root project name, e.g. `my-plugin`. */
    val gradleProjectName: String,
    /** Extra `project.extra` entries for the root project (`root.extra.*` keys). */
    val rootExtraProperties: Map<String, String> = emptyMap(),
    /** Extra Gradle scripts for the root project (`root.gradle.*` keys; values are file paths). */
    val rootExtraGradle: Map<String, String> = emptyMap(),
    /** Extra `project.extra` entries for the `:addon` sub-project (`extra.*` keys). */
    val addonExtraProperties: Map<String, String> = emptyMap(),
    /** Extra Gradle scripts for the `:addon` sub-project (`gradle.*` keys). */
    val addonExtraGradle: Map<String, String> = emptyMap(),
    /** Extra `project.extra` entries for the `:android` sub-project (`extra.*` keys). */
    val androidExtraProperties: Map<String, String> = emptyMap(),
    /** Extra Gradle scripts for the `:android` sub-project (`gradle.*` keys). */
    val androidExtraGradle: Map<String, String> = emptyMap(),
    /** Extra `project.extra` entries for the `:ios` sub-project (`extra.*` keys). */
    val iosExtraProperties: Map<String, String> = emptyMap(),
    /** Extra Gradle scripts for the `:ios` sub-project (`gradle.*` keys). */
    val iosExtraGradle: Map<String, String> = emptyMap(),
) {
    companion object {
        /**
         * Loads a [BuildConfig] from all four properties files.
         *
         * @param gradleRootDir `rootProject.rootDir` - the `gradle/` directory.
         */
        fun load(gradleRootDir: File): BuildConfig {
            val repoRoot     = gradleRootDir.parentFile
            val buildProps   = loadPropsFile(gradleRootDir.resolve("config/build.properties"))
            val addonProps   = loadPropsFile(repoRoot.resolve("addon/config/addon-build.properties"))
            val androidProps = loadPropsFile(repoRoot.resolve("android/config/android-build.properties"))
            val iosProps     = loadPropsFile(repoRoot.resolve("ios/config/ios-build.properties"))

            return BuildConfig(
                gradleProjectName      = buildProps.require("gradleProjectName"),
                rootExtraProperties    = buildProps.extractPrefixed("root.extra."),
                rootExtraGradle        = buildProps.extractPrefixed("root.gradle."),
                addonExtraProperties   = addonProps.extractPrefixed("extra."),
                addonExtraGradle       = addonProps.extractPrefixed("gradle."),
                androidExtraProperties = androidProps.extractPrefixed("extra."),
                androidExtraGradle     = androidProps.extractPrefixed("gradle."),
                iosExtraProperties     = iosProps.extractPrefixed("extra."),
                iosExtraGradle         = iosProps.extractPrefixed("gradle."),
            )
        }

        private fun loadPropsFile(file: File): Properties {
            check(file.exists()) { "Properties file not found: ${file.absolutePath}" }
            return Properties().also { props -> file.inputStream().use { props.load(it) } }
        }
    }
}

private fun Properties.require(key: String): String =
    getProperty(key)?.trim()
        ?: error("Required key '$key' is missing from build.properties.")

private fun Properties.extractPrefixed(prefix: String): Map<String, String> =
    stringPropertyNames()
        .filter { it.startsWith(prefix) }
        .associate { key -> key.removePrefix(prefix) to getProperty(key).trim() }
