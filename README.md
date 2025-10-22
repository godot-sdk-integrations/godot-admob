<p align="center">
	<img width="256" height="256" src="demo/assets/admob-android.png">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<img width="256" height="256" src="demo/assets/admob-ios.png">
</p>

---

# <img src="addon/icon.png" width="24"> Godot Admob Plugin

Godot Admob Plugin provides Godot SDK integrations for [Google Mobile Ads SDK - Android](https://developers.google.com/admob/android) and [Google Mobile Ads SDK - iOS](https://developers.google.com/admob/ios).

_This plugin has been moved under the umbrella of [Godot SDK Integrations](https://github.com/godot-sdk-integrations) organization in Github. Previously, the plugin was placed under three separate repositories: [Android](https://github.com/cengiz-pz/godot-android-admob-plugin), [iOS](https://github.com/cengiz-pz/godot-ios-admob-plugin), and [addon interface](https://github.com/cengiz-pz/godot-admob-addon)._

<br/>

## <img src="addon/icon.png" width="20"> Installation
_Before installing this plugin, make sure to uninstall any previous versions of the same plugin._

_If installing both Android and iOS versions of the plugin in the same project, then make sure that both versions use the same addon interface version._

There are 2 ways to install the `Admob` plugin into your project:
- Through the Godot Editor's AssetLib
- Manually by downloading archives from Github

### <img src="addon/icon.png" width="18"> Installing via AssetLib
Steps:
- search for and select the `Admob` plugin in Godot Editor
- click `Download` button
- on the installation dialog...
	- keep `Change Install Folder` setting pointing to your project's root directory
	- keep `Ignore asset root` checkbox checked
	- click `Install` button
- enable the plugin via the `Plugins` tab of `Project->Project Settings...` menu, in the Godot Editor

#### <img src="addon/icon.png" width="16"> Installing both Android and iOS versions of the plugin in the same project
When installing via AssetLib, the installer may display a warning that states "_[x number of]_ files conflict with your project and won't be installed." You can ignore this warning since both versions use the same addon code.

### <img src="addon/icon.png" width="18"> Installing manually
Steps:
- download release archive from Github
- unzip the release archive
- copy to your Godot project's root directory
- enable the plugin via the `Plugins` tab of `Project->Project Settings...` menu, in the Godot Editor


## <img src="addon/icon.png" width="20"> Supported Ad Types

The following ad types are supported:

- Banner
- Interstitial
- Rewarded
- Rewarded Interstitial
- App Open


## <img src="addon/icon.png" width="20"> Usage
- Add `Admob` node to your main scene and populate the ID fields of the node
	- Debug IDs will only be used when your Godot app is run in debug mode
	- Real IDs will only be used when the `is_real` field of the node is set to `true`

### <img src="addon/icon.png" width="18"> Signals
- register listeners for one or more of the following signals of the `Admob` node:
	- `initialization_completed(status_data: InitializationStatus)`
	- `banner_ad_loaded(ad_id: String)`
	- `banner_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `banner_ad_refreshed(ad_id: String)`
	- `banner_ad_clicked(ad_id: String)`
	- `banner_ad_impression(ad_id: String)`
	- `banner_ad_opened(ad_id: String)`
	- `banner_ad_closed(ad_id: String)`
	- `interstitial_ad_loaded(ad_id: String)`
	- `interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `interstitial_ad_refreshed(ad_id: String)`
	- `interstitial_ad_impression(ad_id: String)`
	- `interstitial_ad_clicked(ad_id: String)`
	- `interstitial_ad_showed_full_screen_content(ad_id: String)`
	- `interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)`
	- `interstitial_ad_dismissed_full_screen_content(ad_id: String)`
	- `rewarded_ad_loaded(ad_id: String)`
	- `rewarded_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `rewarded_ad_impression(ad_id: String)`
	- `rewarded_ad_clicked(ad_id: String)`
	- `rewarded_ad_showed_full_screen_content(ad_id: String)`
	- `rewarded_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)`
	- `rewarded_ad_dismissed_full_screen_content(ad_id: String)`
	- `rewarded_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)`
	- `rewarded_interstitial_ad_loaded(ad_id: String)`
	- `rewarded_interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `rewarded_interstitial_ad_impression(ad_id: String)`
	- `rewarded_interstitial_ad_clicked(ad_id: String)`
	- `rewarded_interstitial_ad_showed_full_screen_content(ad_id: String)`
	- `rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)`
	- `rewarded_interstitial_ad_dismissed_full_screen_content(ad_id: String)`
	- `rewarded_interstitial_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)`
	- `app_open_ad_loaded(ad_unit_id: String)`
	- `app_open_ad_failed_to_load(ad_unit_id: String, error_data: LoadAdError)`
	- `app_open_ad_impression(ad_unit_id: String)`
	- `app_open_ad_clicked(ad_unit_id: String)`
	- `app_open_ad_showed_full_screen_content(ad_unit_id: String)`
	- `app_open_ad_failed_to_show_full_screen_content(ad_unit_id: String, error_data: AdError)`
	- `app_open_ad_dismissed_full_screen_content(ad_unit_id: String)`
	- `consent_form_loaded`
	- `consent_form_dismissed(error_data: FormError)`
	- `consent_form_failed_to_load(error_data: FormError)`
	- `consent_info_updated`
	- `consent_info_update_failed(error_data: FormError)`

### <img src="addon/icon.png" width="18"> Loading and displaying ads
- initialize the plugin
	- call the `initialize()` method of the `Admob` node
	- wait for the `initialization_completed` signal
- use one or more of the following `load_*()` methods to load ads from the `Admob` node:
	- `load_banner_ad(ad_request: LoadAdRequest)`
	- `load_interstitia_adl(ad_request: LoadAdRequest)`
	- `load_rewarded_ad(ad_request: LoadAdRequest)`
	- `load_rewarded_interstitial_ad(ad_request: LoadAdRequest)`
	- `load_app_open_ad(ad_unit_id: String, auto_show_on_resume: boolean)`
- the `Admob` node will emit the following signals once ads have been loaded or failed to load:
	- `banner_ad_loaded(ad_id: String)`
	- `banner_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `interstitial_ad_loaded(ad_id: String)`
	- `interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `rewarded_ad_loaded(ad_id: String)`
	- `rewarded_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `rewarded_interstitial_ad_loaded(ad_id: String)`
	- `rewarded_interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)`
	- `app_open_ad_loaded(ad_unit_id: String)`
	- `app_open_ad_failed_to_load(ad_unit_id: String, error_data: LoadAdError)`
- once ads have been loaded, call corresponding `show_*()` method from the `Admob` node with the `ad_id` received:
	- `show_banner_ad(ad_id: String)`
	- `show_interstitial_ad(ad_id: String)`
	- `show_rewarded_ad(ad_id: String)`
	- `show_rewarded_interstitial_ad(ad_id: String)`
	- `show_app_open_ad()`

### <img src="addon/icon.png" width="18"> Banner Size
- The following methods return the size of a Banner ad:
	- `get_banner_dimension()`
	- `get_banner_dimension_in_pixels()`
- These methods are not supported for `FLUID` sized ads. For banner ads of size `FLUID`, the `get_banner_dimension()` method will return `(-3, -4)` and the `get_banner_dimension_in_pixels()` method will return `(-1, -1)`.

### <img src="addon/icon.png" width="18"> App Open Ads
App open ads are a special ad format intended for publishers wishing to monetize their app load screens. App open ads can be closed at any time, and are designed to be shown at startup or when your users bring your app to the foreground.

Set `auto_show_on_resume` to `true` in order to show app open ads when users resume (bring from background to foreground) your app. The app open ad should be loaded via the `load_app_open_ad()` method before it can be displayed at startup or upon resumption. Ideally, invoke the `load_app_open_ad()` method at startup and, if `auto_show_on_resume` is enabled, upon each `app_open_ad_impression` signal.

### <img src="addon/icon.png" width="18"> User Consent
- Methods:
	- `get_consent_status()` - Returns a consent status value defined in `ConsentInformation.gd`
	- `update_consent_info(params: ConsentRequestParameters)` - To be called if `get_consent_status()` returns status UNKNOWN.
	- `reset_consent_info()` - To be used only when testing and debugging your application.
	- `is_consent_form_available()`
	- `load_consent_form()` - To be called if `get_consent_status()` returns status REQUIRED and `is_consent_form_available()` returns `false`.
	- `show_consent_form()` - To be called after `consent_form_loaded` signal has been emitted or `is_consent_form_available()` returns `true`.

### <img src="addon/icon.png" width="18"> Multi-scene projects

The recommended way to use the `Admob Plugin` in a multi-scene Godot project is as follows:

1. Create a new scene for managing Ads (ie. named `AdManager`).
	 - Attach a script to the root node
2. Add an `Admob` node to the new scene
	 - `@onready`, link to an `admob_node` variable
3. Connect all signals and keep all ad logic in this script
4. From Godot Editor's `Project->Project Settings...` menu, select the `Globals` tab
	 - Set this new scene as an `Autoload`

After setting this scene as an `Autoload`, the `Admob Plugin` methods can be invoked from any scene as shown in the following example:

```
AdManager.admob_node.show_banner()
```

## <img src="addon/icon.png" width="20"> Export
Both `Android` and `iOS` exports require several configuration settings.

### <img src="addon/icon.png" width="18"> File-based Export Configuration
In order to enable file-based export configuration, an `android_export.cfg` or an `ios_export.cfg` file should be placed in the `addons/AdmobPlugin` directory with the file contents formatted as in the example below:

```
[General]
is_real = false

[Debug]
app_id = "ca-app-pub-3940256099942544~3347511713"

[Release]
app_id = "ca-app-pub-3940256099942544~3347511713"
```

The `ios_export.cfg` file supports the following additional properties, which are not relevant for Android.

```
[ATT]
att_enabled = true
att_text = "My ATT text."
```

The `is_real` and `app_id` configuration items are mandatory and if not found in the `export.cfg` file, then the plugin will fall back to node-based configuration.

### <img src="addon/icon.png" width="18"> Node-based Export Configuration
If `<platform>_export.cfg` file is not found for the target platform or file-based configuration fails, then the plugin will attempt to load node-based configuration.

During export, the plugin searches for an `Admob` node in the scene that is open in the Godot Editor. If not found, then the plugin searches for an `Admob` node in the project's main scene. Therefore;
- Make sure that the scene that contains the `Admob` node is selected in the Godot Editor when building and exporting, or
- Make sure that your Godot project's main scene contains an `Admob` node

<br/><br/>

---

# <img src="addon/icon.png" width="24"> Android Admob Plugin

<p align="center">
	<img width="256" height="256" src="demo/assets/admob-android.png">
</p>


## [Android-specific Documentation](android/README.md)
## [AssetLib Entry](https://godotengine.org/asset-library/asset/2548)
## Video Tutorial

[![Godot Android Admob Plugin Video Tutorial](https://img.youtube.com/vi/V9_Gpy0R3RE/0.jpg)](https://www.youtube.com/watch?v=V9_Gpy0R3RE)

<br/><br/>

---

# <img src="addon/icon.png" width="24"> iOS Admob Plugin

<p align="center">
	<img width="256" height="256" src="demo/assets/admob-ios.png">
</p>

## [iOS-specific Documentation](ios/README.md)
## [AssetLib Entry](https://godotengine.org/asset-library/asset/3178)

<br/><br/>

---
# <img src="addon/icon.png" width="24"> All Plugins

| Plugin | Android | iOS |
| :---: | :--- | :--- |
| [Notification Scheduler](https://github.com/godot-sdk-integrations/godot-notification-scheduler) | ✅ | ✅ |
| [Admob](https://github.com/godot-sdk-integrations/godot-admob) | ✅ | ✅ |
| [Deeplink](https://github.com/godot-sdk-integrations/godot-deeplink) | ✅ | ✅ |
| [Share](https://github.com/godot-sdk-integrations/godot-share) | ✅ | ✅ |
| [In-App Review](https://github.com/godot-sdk-integrations/godot-inapp-review) | ✅ | ✅ |

<br/><br/>

---
# <img src="addon/icon.png" width="24"> Credits

Developed by [Cengiz](https://github.com/cengiz-pz)

Android part is based on [Shin-NiL](https://github.com/Shin-NiL)'s [Godot Admob Plugin](https://github.com/Shin-NiL/Godot-Android-Admob-Plugin)

iOS part is based on [Godot iOS Plugin Template](https://github.com/cengiz-pz/godot-ios-plugin-template)

Original repository: [Godot Admob Plugin](https://github.com/godot-sdk-integrations/godot-admob)
