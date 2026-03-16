//
// © 2024-present https://github.com/cengiz-pz
//

apply(from = rootProject.file("config/common.gradle.kts"))

extra.apply {

    // AAR
    set(
        "godotAarUrl",
        "https://github.com/godotengine/godot-builds/releases/download/" +
            "${get("godotVersion")}-${get("godotReleaseType")}/" +
            "godot-lib.${get("godotVersion")}.${get("godotReleaseType")}.template_release.aar",
    )
    set("godotAarFile", "godot-lib-${get("godotVersion")}.${get("godotReleaseType")}.aar")

    // Release archive
    set("pluginArchiveAndroid", "${get("pluginName")}-Android-v${get("pluginVersion")}.zip")

}
