//
// © 2024-present https://github.com/cengiz-pz
//

apply(from = rootProject.file("config/common.gradle.kts"))

extra.apply {

    // Release archive
    set("pluginArchiveiOS", "${get("pluginName")}-iOS-v${get("pluginVersion")}.zip")

}
