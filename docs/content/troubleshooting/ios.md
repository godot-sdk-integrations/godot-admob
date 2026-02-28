---
title: iOS troubleshooting
---

# <img src="../images/icon.png" width="20"> Platform-Specific Notes

- Follow instructions on [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
- **Mediation**: if you have enabled mediation networks, after exporting your project to iOS, open the generated `.xcworkspace`on Xcode (not `.xcodeproj`!)
- **Missing APP ID** crashes: make sure that you
	- enter your Admob APP ID in the Admob node and pay attention to the iOS Export section
	- or enter it in the `android_export.cfg` file as described in the [File-based Export](../export.md) section.
- **Undefined Symbol** linking errors:
	- ensure that `Min iOS version` export setting for your project matches the `platform_version` for the plugin. See [here](https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/ios/config/config.properties).
- View XCode logs while running the game for troubleshooting.
- See [Godot iOS Export Troubleshooting](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html#troubleshooting).
- **App Tracking Transparency**, or ATT for short, is Apple's opt-in privacy framework that requires all iOS apps to ask users for permission to share their data. This is done in the form of a popup where users can either consent or deny tracking.
	- To enable ATT in your app
		- Enter a descriptive text that will be displayed on the ATT dialog in your `Admob` node's `att_text`field.
		- Call `Admob` node's `request_tracking_authorization()` method.
		- Handle `Admob` node's `tracking_authorization_granted` and `tracking_authorization_denied` signals.
		- If the user initially rejects the tracking request, then later on you can check if the user changed their mind and allow them to update their settings by opening the system app settings using the `Admob` node's `open_app_settings()` method.