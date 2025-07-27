<p align="center">
	<img width="256" height="256" src="../demo/assets/admob-ios.png">
</p>

---
# <img src="../addon/icon.png" width="24"> iOS Admob Plugin

Enables AdMob functionality on Godot apps that are exported to the iOS platform and allows 
displaying of Admob ads.

_For Android version, visit https://github.com/cengiz-pz/godot-android-admob-plugin ._

## <img src="../addon/icon.png" width="20"> Prerequisites
Follow instructions on the following page to prepare for iOS export:
- [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)

Create an AdMob account at the following link:
- [Google AdMob](https://admob.google.com/)
- create an app in AdMob console
- [create ad(s)](https://support.google.com/admob/answer/6173650?hl=en) for your app via the AdMob console
- if needed, [create consent form(s)](https://support.google.com/admob/answer/10113207?hl=en) for your app via the AdMob console

## <img src="../addon/icon.png" width="20"> Usage

[Usage documentation](../README.md#usage)


## <img src="../addon/icon.png" width="20"> App Tracking Transparency
App Tracking Transparency, or ATT for short, is Apple's opt-in privacy framework that requires all iOS apps to ask users for permission to share their data. This is done in the form of a popup where users can either consent or deny tracking.

* To enable ATT in your app
	- Enter a descriptive text that will be displayed on the ATT dialog in your `Admob` node's `att_text`field.
	- Call `Admob` node's `request_tracking_authorization()` method.
	- Handle `Admob` node's `tracking_authorization_granted` and `tracking_authorization_denied` signals.
* If the user initially rejects the tracking request, then later on you can check if the user changed their mind and allow them to change their decision by opening the system app settings using the `Admob` node's `open_app_settings()` method.


## <img src="../addon/icon.png" width="20"> Troubleshooting

### Missing APP ID
If your game crashes due to missing APP ID, then make sure that you enter your Admob APP ID in the Admob node and pay attention to the [iOS Export section](#ios-export).

### XCode logs
XCode logs are one of the best tools for troubleshooting unexpected behavior. View XCode logs while running your game to troubleshoot any issues.

### Troubleshooting guide
Refer to Godot's [Troubleshooting Guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#troubleshooting).

<br/><br/>

___

# <img src="../addon/icon.png" width="24"> Contribution

This section provides information on how to build the plugin for contributors.

<br/>

___

## <img src="../addon/icon.png" width="20"> Prerequisites

- [Install SCons](https://scons.org/doc/production/HTML/scons-user/ch01s02.html)
- [Install CocoaPods](https://guides.cocoapods.org/using/getting-started.html)

<br/>

___

## <img src="../addon/icon.png" width="20"> Build

- Run `./script/build.sh -A <godot version>` initially to run a full build
- Run `./script/build.sh -cgA <godot version>` to clean, redownload Godot, and rebuild
- Run `./script/build.sh -ca` to clean and build without redownloading Godot
- Run `./script/build.sh -cb -z4.0` to clean and build plugin without redownloading Godot and package in a zip archive as version 4.0
- Run `./script/build.sh -h` for more information on the build script

<br/>

___

## <img src="../addon/icon.png" width="20"> Install Script

- Run `./script/install.sh -t <target directory> -z <path to zip file>` install plugin to a Godot project.
- Example `./script/install.sh -t ../demo -z bin/release/AdmobPlugin-v4.0.zip` to install to demo app.

<br/>

___

## ![](../addon/icon.png?raw=true) Libraries

Library archives will be created in the `build/release` directory.
