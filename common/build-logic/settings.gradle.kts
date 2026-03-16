//
// © 2026-present https://github.com/cengiz-pz
//

// Included build: provides shared convention plugins and build-logic classes
// to all subprojects. Declared in the root settings.gradle.kts via:
//   includeBuild("build-logic")
//

dependencyResolutionManagement {
    repositories {
        mavenCentral()
    }
    // Reuse the root project's version catalog so plugin versions stay in sync
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}

rootProject.name = "build-logic"
