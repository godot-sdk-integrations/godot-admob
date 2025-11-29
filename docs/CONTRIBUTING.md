# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="28"> Contributing

This section provides information on how to build the plugin for contributors.

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Configuration

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Common Configuration

The `common/config.properties` file allows for the configuration of:

- The name of the main plugin node in Godot
- Plugin version
- Version of Godot that the plugin depends on
- Release type of the Godot version to download (ie. stable, dev6, or beta3)

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Android Configuration

The `android/gradle/lib.versions.toml` contains:

- Gradle plugins and their versions
- Library dependencies and their versions

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Configuration

Among other settings, the `ios/config/config.properties` file allows for the configuration of:

- The target iOS platform version
- Valid/compatible Godot versions

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Build

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Android Builds

**Options:**
1. Use [Android Studio](https://developer.android.com/studio) to build via **Build->Assemble Project** menu
    - Switch **Active Build Variant** to **release** and repeat
    - Run **packageDistribution** task to create release archive
2. Use project-root-level **build.sh** script
    - `./script/build.sh -ca` - clean existing build, do a debug build for Android
    - `./script/build.sh -carz` - clean existing build, do a release build for Android, and create release archive in the `android/<plugin-name>/build/dist` directory

#### Build All and Create Release Archives for Both Platforms

- Run `./script/build.sh -R` -- creates all 3 archives in the `./release` directory

---

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Build Prerequisites

- [Install SCons](https://scons.org/doc/production/HTML/scons-user/ch01s02.html)
- [Install CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Builds
iOS build script can be run directly as shown in the examples below.

- Run `./script/build_ios.sh -A` initially to run a full build
- Run `./script/build_ios.sh -cgA` to clean, redownload Godot, and rebuild
- Run `./script/build_ios.sh -ca` to clean and build without redownloading Godot
- Run `./script/build_ios.sh -cbz` to clean and build plugin without redownloading Godot and package in a zip archive
- Run `./script/build_ios.sh -h` for more information on the build script

Alternatively, iOS build script can be run through the root-level build script as follows

- Run `./script/build.sh -i -- -cbz` to clean and build plugin without redownloading Godot and package in a zip archive
- Run `./script/build.sh -i -- -h` for more information on the build script

___

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> iOS Libraries

iOS library archives will be created in the `ios/build/release` directory.

___

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Release

- Run `./script/build.sh -A` to create Android release archive
- Run `./script/build.sh -I` to create iOS release archive
- Run `./script/build.sh -R` to create Android, iOS and multi-platform release archives

___

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="24"> Install

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/icon.png" width="20"> Install Script

- Run `./script/install.sh -t <target directory> -z <path to zip file>` install plugin to a Godot project.
- Example `./script/install.sh -t demo -z build/release/ThisPlugin-v4.0.zip` to install to demo app.
- Alternatively, `./script/build.sh -D` to install iOS archive to demo app.
