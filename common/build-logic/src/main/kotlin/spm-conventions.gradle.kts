//
// © 2026-present https://github.com/cengiz-pz
//

//
// Convention plugin: spm-conventions
//
// Apply in any subproject that needs to read spm_dependencies.json:
//
//   plugins {
//       id("spm-conventions")
//   }
//
// Applying this plugin puts SpmDependency and readSpmDependencies() on the
// subproject's build-script classpath via the included build mechanism.
//

import kotlinx.serialization.json.Json

/**
 * Reads SPM dependency entries from an spm_dependencies.json config file.
 *
 * Each entry in the JSON array has the form:
 *   { "url": "<URL>", "version": "<minimumVersion>", "products": ["<ProductName>", ...] }
 *
 * Returns a list of [SpmDependency] objects decoded via kotlinx.serialization.
 */
fun readSpmDependencies(configFile: File): List<SpmDependency> {
    if (!configFile.exists()) return emptyList()
    return Json.decodeFromString<List<SpmDependency>>(configFile.readText())
}

// Expose readSpmDependencies as a project-level extra so consuming build
// scripts can invoke it without redeclaring it.
project.extensions.extraProperties["readSpmDependencies"] =
    ::readSpmDependencies
