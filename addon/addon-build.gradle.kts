//
// © 2024-present https://github.com/cengiz-pz
//

plugins {
    id("base-conventions")
}

// -- Load config data class ----------------------------------------------------
//
// All project.extra values (templateDir, outputDir, iosFrameworks, etc.) are
// already set by base-conventions.  pluginConfig is loaded here for typed
// member access (pluginConfig.pluginName, .iosInitializationMethod, …) directly
// in task registration blocks, which is cleaner than casting from project.extra.

val pluginConfig = loadPluginConfig()

// -- Collect all catalog library aliases (used in @androidDependencies@ token) -

val androidDependencies =
    extensions
        .getByType<VersionCatalogsExtension>()
        .named("libs")
        .run { libraryAliases.map { findLibrary(it).get().get() } }

// -- Helpers -------------------------------------------------------------------

/** Wraps each item in a [List] in double-quotes and joins with ", ". */
fun List<String>.toQuotedString(): String = joinToString(", ") { "\"$it\"" }

/**
 * Formats a list of [SpmDependency] items into the GDScript dictionary literal
 * format used as the body of a `const SPM_DEPENDENCIES: Array = [ @spmDependencies@ ]`
 * token substitution.
 *
 * Each dependency becomes a GDScript dictionary with [StringName] keys (the `&"key"`
 * syntax), e.g.:
 * ```
 * {&"url": "https://github.com/owner/repo", &"version": "1.2.3", &"products": ["ProductA", "ProductB"]}
 * ```
 *
 * Multiple entries are joined with `, `. The surrounding square brackets are
 * intentionally omitted because they are already present in the GDScript constant
 * declaration that hosts the `@spmDependencies@` token.
 */
fun List<SpmDependency>.toGdscriptFormat(): String =
    joinToString(", ") { dep ->
        val products = dep.products.joinToString(", ") { "\"$it\"" }
        """{&"url": "${dep.url}", &"version": "${dep.version}", &"products": [$products]}"""
    }

/**
 * Registers a GDScript format task (check or in-place fix).
 *
 * Both [checkGdscriptFormat] and [formatGdscriptSource] share identical source-file
 * discovery, gdformatrc lifecycle, and working directory - only the gdformat flag differs.
 *
 * If a `src/shared/` sibling directory exists alongside the src/main directory, its GDScript
 * files are included in formatting as well, and the `.gdformatrc` config is temporarily
 * copied there so that gdformat can locate it when traversing up from shared file paths.
 */
fun TaskContainerScope.registerGdscriptFormatTask(
    name: String,
    description: String,
    check: Boolean,
) {
    // extra["templateDir"] / extra["sharedTemplateDir"] are set by base-conventions
    // and resolve to this project's src/main and src/shared directories.
    val addonSrcDir = file(extra["templateDir"] as String)
    val sharedSrcDir = file(extra["sharedTemplateDir"] as String)
    val gdformatrcSource = file("$projectDir/../.github/config/.gdformatrc")
    val gdformatrcDest = addonSrcDir.resolve(".gdformatrc")
    val sharedGdformatrcDest = sharedSrcDir.resolve(".gdformatrc")
    val excludePatterns = listOf("**/*Plugin.gd", "**/MediationNetwork.gd")

    register<Exec>(name) {
        this.description = description
        this.group = if (check) "verification" else "formatting"

        workingDir = addonSrcDir

        doFirst {
            copy {
                from(gdformatrcSource)
                into(addonSrcDir)
            }
            if (sharedSrcDir.exists()) {
                copy {
                    from(gdformatrcSource)
                    into(sharedSrcDir)
                }
            }

            val sourceFiles =
                buildList {
                    addAll(
                        fileTree(addonSrcDir) {
                            include("**/*.gd")
                            excludePatterns.forEach { exclude(it) }
                        }.files,
                    )
                    if (sharedSrcDir.exists()) {
                        addAll(fileTree(sharedSrcDir) { include("**/*.gd") }.files)
                    }
                    addAll(
                        fileTree("${rootProject.projectDir}/../demo") {
                            include("**/*.gd")
                            exclude("addons/**")
                        }.files,
                    )
                }.map { it.relativeTo(addonSrcDir).path }
                    .sorted()

            if (sourceFiles.isEmpty()) {
                throw GradleException("$name: no source files found under ${addonSrcDir.absolutePath}")
            }

            commandLine(
                buildList {
                    add("gdformat")
                    if (check) add("--check")
                    addAll(sourceFiles)
                },
            )
        }

        doLast {
            if (gdformatrcDest.exists()) gdformatrcDest.delete()
            if (sharedGdformatrcDest.exists()) sharedGdformatrcDest.delete()
        }
    }
}

// -- Tasks ---------------------------------------------------------------------

tasks {
    // Capture project.extra values at TaskContainerScope level - before any
    // register() call - to avoid the task-receiver scoping trap where bare
    // `extra["key"]` inside a register { } block resolves to the task's own
    // (empty) ExtraPropertiesExtension instead of the project's.
    val addonSrcDir = file(extra["templateDir"] as String)
    val sharedSrcDir = file(extra["sharedTemplateDir"] as String)
    val outputDir = extra["outputDir"] as String
    val iosPlatformVersion = extra["iosPlatformVersion"] as String

    @Suppress("UNCHECKED_CAST")
    val iosFrameworks = extra["iosFrameworks"] as List<String>

    @Suppress("UNCHECKED_CAST")
    val iosEmbeddedFrameworks = extra["iosEmbeddedFrameworks"] as List<String>

    @Suppress("UNCHECKED_CAST")
    val iosLinkerFlags = extra["iosLinkerFlags"] as List<String>

    @Suppress("UNCHECKED_CAST")
    val iosSpmDependencies = extra["iosSpmDependencies"] as List<SpmDependency>

    register<Delete>("cleanOutput") {
        group = "clean"
        delete(
            fileTree(outputDir) {
                include("**/*.gd", "**/*.cfg", "**/*.png", "**/*.gdip")
            },
        )
        delete(
            fileTree("$outputDir/ios/plugins") {
                include("**/*")
            },
        )
    }

    register<Copy>("copyAssets") {
        description = "Copies plugin assets such as PNG images to the output directory"
        group = "generate"
        from(addonSrcDir)
        into("$outputDir/addons/${pluginConfig.pluginName}")
        include("**/*.png")
        inputs.files(fileTree(addonSrcDir) { include("**/*.png") })
    }

    register<Copy>("generateSharedGDScript") {
        description = "Copies shared GDScript templates to the GMPShared output directory and replaces tokens"
        group = "generate"
        onlyIf("shared source directory contains GDScript or config files") {
            sharedSrcDir.exists() &&
                fileTree(sharedSrcDir) { include("**/*.gd", "**/*.cfg") }.files.isNotEmpty()
        }

        from(sharedSrcDir)
        into("$outputDir/addons/GMPShared")
        include("**/*.gd", "**/*.cfg")

        eachFile { println("[DEBUG] Processing shared file $relativePath") }

        val allTokens: Map<String, String> =
            buildMap {
                project.extra.properties.forEach { (k, v) ->
                    val raw = v.toString()
                    put(
                        k,
                        if (raw.contains(",")) {
                            raw.split(",").joinToString(", ") { "\"${it.trim()}\"" }
                        } else {
                            raw
                        },
                    )
                }
                put("androidDependencies", androidDependencies.joinToString(", ") { "\"$it\"" })
                put("iosFrameworks", iosFrameworks.toQuotedString())
                put("iosEmbeddedFrameworks", iosEmbeddedFrameworks.toQuotedString())
                put("iosLinkerFlags", iosLinkerFlags.toQuotedString())
                put("spmDependencies", iosSpmDependencies.toGdscriptFormat())
            }

        filter { line: String ->
            allTokens.entries.fold(line) { acc, (key, value) ->
                val token = "@$key@"
                if (acc.contains(token)) {
                    println("\t[DEBUG] Replacing token $token with: $value")
                    acc.replace(token, value)
                } else {
                    acc
                }
            }
        }

        if (sharedSrcDir.exists()) inputs.dir(sharedSrcDir)
        inputs.files(
            rootProject.file("config/plugin.properties"),
            rootProject.file("../ios/config/ios.properties"),
            rootProject.file("../ios/config/spm_dependencies.json"),
        )
        inputs.property("pluginName", pluginConfig.pluginName)
        inputs.property("pluginNodeName", pluginConfig.pluginNodeName)
        inputs.property("pluginVersion", pluginConfig.pluginVersion)
        inputs.property("pluginPackage", pluginConfig.pluginPackageName)
        inputs.property("androidDependencies", androidDependencies.joinToString())
        inputs.property("iosPlatformVersion", iosPlatformVersion)
        inputs.property("iosFrameworks", iosFrameworks.joinToString())
        inputs.property("iosEmbeddedFrameworks", iosEmbeddedFrameworks.joinToString())
        inputs.property("iosLinkerFlags", iosLinkerFlags.joinToString())
        inputs.property("iosSpmDependencies", iosSpmDependencies.joinToString())

        outputs.dir("$outputDir/addons/GMPShared")
    }

    register<Copy>("generateGDScript") {
        description = "Copies the GDScript templates and plugin config to the output directory and replaces tokens"
        group = "generate"
        dependsOn("generateSharedGDScript")
        finalizedBy("copyAssets")

        from(addonSrcDir)
        into("$outputDir/addons/${pluginConfig.pluginName}")
        include("**/*.gd", "**/*.cfg")

        eachFile { println("[DEBUG] Processing file: $relativePath") }

        val allTokens: Map<String, String> =
            buildMap {
                project.extra.properties.forEach { (k, v) ->
                    val raw = v.toString()
                    put(
                        k,
                        if (raw.contains(",")) {
                            raw.split(",").joinToString(", ") { "\"${it.trim()}\"" }
                        } else {
                            raw
                        },
                    )
                }
                put("androidDependencies", androidDependencies.joinToString(", ") { "\"$it\"" })
                put("iosFrameworks", iosFrameworks.toQuotedString())
                put("iosEmbeddedFrameworks", iosEmbeddedFrameworks.toQuotedString())
                put("iosLinkerFlags", iosLinkerFlags.toQuotedString())
                put("spmDependencies", iosSpmDependencies.toGdscriptFormat())
            }

        filter { line: String ->
            allTokens.entries.fold(line) { acc, (key, value) ->
                val token = "@$key@"
                if (acc.contains(token)) {
                    println("\t[DEBUG] Replacing token $token with: $value")
                    acc.replace(token, value)
                } else {
                    acc
                }
            }
        }

        inputs.dir(addonSrcDir)
        inputs.files(
            rootProject.file("config/plugin.properties"),
            rootProject.file("../ios/config/ios.properties"),
            rootProject.file("../ios/config/spm_dependencies.json"),
        )
        inputs.property("pluginName", pluginConfig.pluginName)
        inputs.property("pluginNodeName", pluginConfig.pluginNodeName)
        inputs.property("pluginVersion", pluginConfig.pluginVersion)
        inputs.property("pluginPackage", pluginConfig.pluginPackageName)
        inputs.property("androidDependencies", androidDependencies.joinToString())
        inputs.property("iosPlatformVersion", iosPlatformVersion)
        inputs.property("iosFrameworks", iosFrameworks.joinToString())
        inputs.property("iosEmbeddedFrameworks", iosEmbeddedFrameworks.joinToString())
        inputs.property("iosLinkerFlags", iosLinkerFlags.joinToString())
        inputs.property("iosSpmDependencies", iosSpmDependencies.joinToString())

        outputs.dir("$outputDir/addons/${pluginConfig.pluginName}")
    }

    register<Copy>("generateiOSConfig") {
        description = "Copies the iOS plugin config to the output directory and replaces tokens"
        group = "generate"
        mustRunAfter("generateGDScript")

        from("${rootProject.projectDir}/../ios/config")
        into("$outputDir/ios/plugins")
        include("**/*.gdip")

        eachFile { println("[DEBUG] Processing file: $relativePath") }

        val tokens =
            mapOf(
                "pluginName" to pluginConfig.pluginName,
                "iosInitializationMethod" to pluginConfig.iosInitializationMethod,
                "iosDeinitializationMethod" to pluginConfig.iosDeinitializationMethod,
            )

        filter { line: String ->
            tokens.entries.fold(line) { acc, (key, value) ->
                val token = "@$key@"
                if (acc.contains(token)) {
                    println("\t[DEBUG] Replacing token $token with: $value")
                    acc.replace(token, value)
                } else {
                    acc
                }
            }
        }

        inputs.files(
            rootProject.file("config/plugin.properties"),
            rootProject.file("../ios/config/ios.properties"),
        )
        inputs.property("pluginName", pluginConfig.pluginName)
        inputs.property("iosInitializationMethod", pluginConfig.iosInitializationMethod)
        inputs.property("iosDeinitializationMethod", pluginConfig.iosDeinitializationMethod)

        outputs.dir("$outputDir/ios/plugins")
    }

    registerGdscriptFormatTask(
        name = "checkGdscriptFormat",
        description = "Checks gdscript-formatter compliance of GDScript source files (dry-run)",
        check = true,
    )

    registerGdscriptFormatTask(
        name = "formatGdscriptSource",
        description = "Formats GDScript source files in-place using gdscript-formatter",
        check = false,
    )
}
