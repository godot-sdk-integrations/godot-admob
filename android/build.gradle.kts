//
// © 2024-present https://github.com/cengiz-pz
//

import com.android.build.gradle.internal.api.LibraryVariantOutputImpl
import com.github.gradle.node.npm.task.NpmTask
import com.github.gradle.node.npm.task.NpxTask
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.undercouch.download)
    alias(libs.plugins.openrewrite)
    alias(libs.plugins.node)
}

apply(from = "$projectDir/config/android.gradle.kts")

configure<org.openrewrite.gradle.RewriteExtension> {
    activeRecipe(
        "org.openrewrite.java.format.AutoFormat",
        "org.openrewrite.java.RemoveUnusedImports",
        "org.openrewrite.staticanalysis.NeedBraces",
        "org.openrewrite.java.format.RemoveTrailingWhitespace",
    )
    activeStyle("org.godotengine.plugin.JavaStyle")

    // Path to the rewrite.yml defining the named style
    configFile = projectDir.resolve("config/rewrite.yml")
}

android {
    namespace = project.extra["pluginPackageName"] as String
    compileSdk =
        libs.versions.compileSdk
            .get()
            .toInt()

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        minSdk =
            libs.versions.minSdk
                .get()
                .toInt()

        manifestPlaceholders["godotPluginName"] = project.extra["pluginName"] as String
        manifestPlaceholders["godotPluginPackageName"] = project.extra["pluginPackageName"] as String
        buildConfigField("String", "GODOT_PLUGIN_NAME", "\"${project.extra["pluginName"]}\"")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    buildToolsVersion = libs.versions.buildTools.get()

    // Force AAR filenames to match original case and format
    libraryVariants.all {
        outputs.all {
            val outputImpl = this as LibraryVariantOutputImpl
            val buildType = name // "debug" or "release"
            outputImpl.outputFileName = "${project.extra["pluginName"]}-$buildType.aar"
        }
    }
}

androidComponents {
    beforeVariants(selector().all()) { variantBuilder ->
        // Disables unit tests
        variantBuilder.enableUnitTest = false
        // Disables instrumented tests
        variantBuilder.androidTest.enable = false
    }
}

node {
    download = true
    version =
        libs.versions.node.env
            .get()
}

// Access the library catalog by name ("libs")
val catalog = extensions.getByType<VersionCatalogsExtension>().named("libs")

// Map all library aliases to their actual dependency provider
val androidDependencies =
    catalog.libraryAliases
        .filter { it != "rewrite.static.analysis" }
        .map { alias ->
            catalog
                .findLibrary(alias)
                .get()
                .get()
        }

dependencies {
    "rewrite"(libs.rewrite.static.analysis)

    implementation("godot:godot-lib:${project.extra["godotVersion"]}.${project.extra["godotReleaseType"]}@aar")
    androidDependencies.forEach {
        println("[DEBUG] Adding Android dependency: $it")
        implementation(it)
    }
}

tasks {
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra
    val archiveDir: String by project.extra
    val demoDir: String by project.extra

    register<Copy>("buildAndroidDebug") {
        description = "Copies the generated GDScript and debug AAR binary to the plugin directory"

        dependsOn(
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("copyAssets"),
            project(":android").tasks.named("assembleDebug"),
        )

        into("$pluginDir/android")

        from("$repositoryRootDir/addon/build/output") {
            include("addons/${project.extra["pluginName"]}/**")
        }

        from("$projectDir/build/outputs/aar") {
            include("${project.extra["pluginName"]}-debug.aar")
            into("addons/${project.extra["pluginName"]}/bin/debug")
        }

        doLast {
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
            val current = LocalDateTime.now().format(formatter)
            println("Android debug build completed at: $current")
        }

        outputs.dir("$pluginDir/android")
    }

    register<Copy>("buildAndroidRelease") {
        description = "Copies the generated GDScript and release AAR binary to the plugin directory"

        dependsOn(
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("copyAssets"),
            project(":android").tasks.named("assembleRelease"),
        )

        into("$pluginDir/android")

        from("$repositoryRootDir/addon/build/output") {
            include("addons/${project.extra["pluginName"]}/**")
        }

        from("$projectDir/build/outputs/aar") {
            include("${project.extra["pluginName"]}-release.aar")
            into("addons/${project.extra["pluginName"]}/bin/release")
        }

        doLast {
            val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
            val current = LocalDateTime.now().format(formatter)
            println("Android release build completed at: $current")
        }

        outputs.dir("$pluginDir/android")
    }

    register("buildAndroid") {
        description = "Builds both debug and release"

        dependsOn(
            "buildAndroidDebug",
            "buildAndroidRelease",
        )
    }

    register<Zip>("createAndroidArchive") {
        dependsOn(
            "buildAndroidDebug",
            "buildAndroidRelease",
        )

        val archiveName = project.extra["pluginArchiveAndroid"] as String
        val sourceDir = "$pluginDir/android"

        archiveFileName.set(archiveName)
        destinationDirectory.set(layout.projectDirectory.dir(archiveDir))

        into("res") {
            from(layout.projectDirectory.dir(sourceDir)) {
                includeEmptyDirs = false
            }
        }

        doLast {
            println("Android zip archive created at: ${archiveFile.get().asFile.path}")
        }
    }

    register<Copy>("installToDemoAndroid") {
        description = "Copies the assembled Android plugin to demo application's addons directory"

        dependsOn(
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("copyAssets"),
            "buildAndroidDebug",
        )

        destinationDir = file(demoDir)

        duplicatesStrategy = DuplicatesStrategy.WARN

        into(".") {
            from("$pluginDir/android")
        }

        outputs.dir(destinationDir)
    }

    register<Delete>("uninstallAndroid") {
        description = "Keep demo app's plugin directory and delete everything inside except for .uid and .import files"
        delete(
            fileTree("$demoDir/addons/${project.extra["pluginName"]}").apply {
                include("**/*")
                exclude("**/*.uid")
                exclude("**/*.import")
            },
        )
    }

    register<NpmTask>("installPrettier") {
        args.set(listOf("install", "--save-dev", "prettier", "@prettier/plugin-xml"))
    }

    register<NpxTask>("checkXmlFormat") {
        dependsOn("installPrettier")
        command.set("prettier")
        args.set(
            listOf(
                "--config",
                "../.github/config/prettier.xml.json",
                "--parser",
                "xml",
                "--check",
                "src/**/*.xml",
            ),
        )
    }

    register<NpxTask>("formatXml") {
        dependsOn("installPrettier")
        command.set("prettier")
        args.set(
            listOf(
                "--config",
                "../.github/config/prettier.xml.json",
                "--parser",
                "xml",
                "--write",
                "src/**/*.xml",
            ),
        )
    }

    register<de.undercouch.gradle.tasks.download.Download>("downloadGodotAar") {
        val destFile = file("${gradle.extra["libDir"]}/${project.extra["godotAarFile"]}")

        val godotAarUrl = project.extra["godotAarUrl"] as String
        inputs.property("godotAarUrl", godotAarUrl)
        outputs.file(destFile)

        src(godotAarUrl)
        dest(destFile)
        overwrite(false)

        onlyIf {
            val exists = destFile.exists() && destFile.length() > 0
            if (exists) {
                println(
                    "[GODOT-AAR] File already exists and is non-empty: " +
                        "${destFile.absolutePath} (${destFile.length()} bytes)",
                )
                println("[GODOT-AAR] Skipping download.")
            } else {
                if (destFile.exists()) {
                    println("[GODOT-AAR] File exists but is empty: ${destFile.absolutePath}")
                } else {
                    println("[GODOT-AAR] File not found: ${destFile.absolutePath}")
                }
                println("[GODOT-AAR] Proceeding with download...")
            }
            !exists // run task only if file does NOT exist or is empty
        }
    }

    named("preBuild") {
        dependsOn("downloadGodotAar")
    }
}
