//
// © 2026-present https://github.com/cengiz-pz
//

// Compiles all convention plugins (precompiled script plugins) in
// src/main/kotlin/*.gradle.kts and makes them — together with their
// runtime dependencies — available to every subproject that applies them.
//
// Versions are kept in sync with gradle/libs.versions.toml via the
// version catalog re-export in settings.gradle.kts:
//   kotlin-android-plugin  →  kotlin("plugin.serialization")
//   kotlinx-serialization  →  kotlinx-serialization-json runtime
//

plugins {
    `kotlin-dsl`
    alias(libs.plugins.kotlin.serialization)
}

dependencies {
    implementation(libs.kotlinx.serialization.json)
}
