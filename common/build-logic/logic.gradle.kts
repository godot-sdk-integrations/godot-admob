//
// © 2026-present https://github.com/cengiz-pz
//

// Compiles all convention plugins (precompiled script plugins) in
// src/main/java/*.gradle.kts and makes them - together with their
// runtime dependencies - available to every subproject that applies them.
//
// Versions are kept in sync with gradle/libs.versions.toml via the
// version catalog re-export in settings.gradle.kts:
//   kotlin-android-plugin  ->  kotlin("plugin.serialization")
//   kotlinx-serialization  ->  kotlinx-serialization-json runtime
//

plugins {
    `kotlin-dsl`
    `java-gradle-plugin`
    alias(libs.plugins.kotlin.serialization)
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

kotlin {
    jvmToolchain(17)
}

gradlePlugin {
    plugins {
        create("baseConventions") {
            id = "base-conventions"
            implementationClass = "BaseConventionsPlugin"
            description = "Godot Mobile Plugins base conventions plugin"
        }
    }
}

val buildLogicDependencies =
    extensions
        .getByType<VersionCatalogsExtension>()
        .named("libs")
        .run {
            libraryAliases
                .filter { it.startsWith("build.logic.") }
                .map { findLibrary(it).get().get() }
        }

dependencies {
    implementation(gradleKotlinDsl())

    buildLogicDependencies.forEach {
        implementation(it)
    }
}

sourceSets {
    main {
        java.srcDirs("src/main/java")
        resources.srcDirs("src/main/resources")
    }
}

kotlin.sourceSets.getByName("main") {
    kotlin.srcDirs("src/main/kotlin", "src/main/java")
}
