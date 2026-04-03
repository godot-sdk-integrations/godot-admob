//
// © 2026-present https://github.com/cengiz-pz
//

import java.io.File
import java.util.Properties

/**
 * Immutable value object holding every setting from `common/config/plugin.properties`.
 *
 * Obtain an instance via [Project.loadPluginConfig] (defined in `ProjectExtensions.kt`),
 * which is available in any project build script that applies `id("base-conventions")`:
 *
 * ```kotlin
 * plugins { id("base-conventions") }
 *
 * val pluginConfig = loadPluginConfig()
 * println(pluginConfig.pluginName)       // "MyPlugin"
 * println(pluginConfig.pluginVersion)    // "1.0"
 * ```
 *
 * Derived properties ([pluginName], [iosInitializationMethod], [iosDeinitializationMethod])
 * are computed from the raw values and are never stored in the `.properties` file.
 */
data class PluginConfig(
    /** Human-readable node name, e.g. `PluginTemplate`. */
    val pluginNodeName: String,
    /** Snake-case native module name, e.g. `plugin_template`. */
    val pluginModuleName: String,
    /** Fully-qualified Java/Kotlin package, e.g. `org.godotengine.plugin.plugintemplate`. */
    val pluginPackageName: String,
    /** Semantic version string, e.g. `1.0`. */
    val pluginVersion: String,
) {
    /** Full plugin name used for AAR filenames and GDScript class names, e.g. `PluginTemplatePlugin`. */
    val pluginName: String
        get() = "${pluginNodeName}Plugin"

    /** iOS gdnlib initialisation symbol, e.g. `plugin_template_plugin_init`. */
    val iosInitializationMethod: String
        get() = "${pluginModuleName}_plugin_init"

    /** iOS gdnlib de-initialisation symbol, e.g. `plugin_template_plugin_deinit`. */
    val iosDeinitializationMethod: String
        get() = "${pluginModuleName}_plugin_deinit"

    companion object {
        /**
         * Loads a [PluginConfig] from `config/plugin.properties` inside [gradleRootDir]
         * (i.e. `rootProject.rootDir`).
         */
        fun load(gradleRootDir: File): PluginConfig {
            val file = gradleRootDir.resolve("config/plugin.properties")
            check(file.exists()) { "Plugin properties file not found: ${file.absolutePath}" }
            val props = Properties().also { it.load(file.inputStream()) }
            return PluginConfig(
                pluginNodeName    = props.require("pluginNodeName"),
                pluginModuleName  = props.require("pluginModuleName"),
                pluginPackageName = props.require("pluginPackage"),
                pluginVersion     = props.require("pluginVersion"),
            )
        }
    }
}

private fun Properties.require(key: String): String =
    getProperty(key)?.trim()
        ?: error("Required key '$key' is missing from plugin.properties.")
