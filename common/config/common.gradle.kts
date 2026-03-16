//
// © 2024-present https://github.com/cengiz-pz
//

import java.io.FileInputStream
import java.util.Properties

val commonProperties =
    Properties().apply {
        load(FileInputStream("$rootDir/config/config.properties"))
    }

extra.apply {
    // Plugin details
    set("pluginNodeName", commonProperties.getProperty("pluginNodeName"))
    set("pluginName", "${get("pluginNodeName")}Plugin")
    set("pluginModuleName", "${commonProperties.getProperty("pluginModuleName")}")
    set("pluginPackageName", commonProperties.getProperty("pluginPackage"))
    set("pluginVersion", commonProperties.getProperty("pluginVersion"))

    // Godot
    set("godotVersion", commonProperties.getProperty("godotVersion"))
    set("godotReleaseType", commonProperties.getProperty("godotReleaseType"))

    // Project directories
    set("pluginDir", "$rootDir/build/plugin")
    set("repositoryRootDir", "$rootDir/..")
    set("archiveDir", "${get("repositoryRootDir")}/release")
    set("demoDir", "${get("repositoryRootDir")}/demo")

    // Release archive
    set("pluginArchiveMulti", "${get("pluginName")}-Multi-v${get("pluginVersion")}.zip")
}
