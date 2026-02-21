<div align="center">
	<img width="128" height="128" src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/demo/assets/admob-android.png">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<img width="128" height="128" src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/demo/assets/admob-ios.png">
</div>

---

<div align="center">
	<a href="https://github.com/godot-sdk-integrations/godot-admob">
	<img src="https://img.shields.io/github/stars/godot-sdk-integrations/godot-admob?style=social" />
	</a>
	<img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/total" />
	<img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/latest/total" />
	<img src="https://img.shields.io/github/v/release/godot-sdk-integrations/godot-admob" />
</div>

---

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Godot Admob Plugin

A Godot plugin that provides a unified GDScript interface for integrating **Google Mobile Ads SDK** on **Android** and **iOS**.

**Key Features:**
- Load and show...
	- Banner Ads
		- Fixed-size
		- Adaptive
		- Inline-adaptive
		- Collapsible
	- Interstitial Ads
	- Rewarded Video Ads
	- Rewarded Interstitial Ads
	- App Open Ads
- Emits signals when ads are loaded, viewed, clicked, dismissed, rewards received, & more
- Allows configuration of all settings on a node
- Works with Google AdMob ad network by default
- Allows enabling of up to 15 additional ad mediation networks
- Supports global ad settings
- Supports UMP consent flows
- Provides two export configuration options:
	- Node-based
	- File-based

---

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Signals](#signals)
- [Methods](#methods)
- [Classes](#classes)
- [Nodes](#nodes)
- [Banner Ads](#banner-ads)
- [App Open Ads](#app-open-ads)
- [User Consent](#user-consent)
- [Multi-scene Projects](#multi-scene-projects)
- [Mediation](#mediation)
- [Export](#export)
- [Platform-Specific Notes](#platform-specific-notes)
- [General Troubleshooting](#general-troubleshooting)
- [Video Tutorials](#video-tutorials)
- [Links](#links)
- [All Plugins](#all-plugins)
- [Credits](#credits)
- [Contributing](#contributing)

---

<a name="prerequisites"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Prerequisites
Create an AdMob account at the following link:
- [Google AdMob](https://admob.google.com/)

Using the AdMob console:
- create an app and link it to the app's store listing
- [create ad(s)](https://support.google.com/admob/answer/6173650?hl=en) for your app via the AdMob console
- if needed, [create consent form(s)](https://support.google.com/admob/answer/10113207?hl=en) for your app via the AdMob console

---

<a name="installation"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Installation
_Before installing this plugin, make sure to uninstall any previous versions of the same plugin._

_If installing both Android and iOS versions of the plugin in the same project, then make sure that both versions use the same addon interface version._

There are 2 ways to install the `Admob` plugin into your project:
- Through the Godot Editor's AssetLib
- Manually by downloading archives from Github

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Installing via AssetLib
Steps:
- search for and select the `Admob` plugin in Godot Editor
- click `Download` button
- on the installation dialog...
	- keep `Change Install Folder` setting pointing to your project's root directory
	- keep `Ignore asset root` checkbox checked
	- click `Install` button
- enable the plugin via the `Plugins` tab of `Project->Project Settings...` menu, in the Godot Editor

#### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Installing both Android and iOS versions of the plugin in the same project
When installing via AssetLib, the installer may display a warning that states "_[x number of]_ files conflict with your project and won't be installed." You can ignore this warning since both versions use the same addon code.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Installing manually
Steps:
- download release archive from Github
- unzip the release archive
- copy to your Godot project's root directory
- enable the plugin via the `Plugins` tab of `Project->Project Settings...` menu, in the Godot Editor


## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Supported Ad Types

The following ad types are supported:

- Banner
- Interstitial
- Rewarded
- Rewarded Interstitial
- App Open

---

<a name="usage"></a>


## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Usage
- Add `Admob` node to your main scene and populate the ID fields of the node
	- Debug IDs will only be used when your Godot app is run in debug mode
	- Real IDs will only be used when the `is_real` field of the node is set to `true`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Loading and displaying ads
- initialize the plugin
	- call the `initialize()` method of the `Admob` node
	- wait for the `initialization_completed` signal
- use one or more of the following `load_*()` methods to load ads from the `Admob` node:
	- `load_banner_ad(ad_request: LoadAdRequest)`
	- `load_interstitial_ad(ad_request: LoadAdRequest)`
	- `load_rewarded_ad(ad_request: LoadAdRequest)`
	- `load_rewarded_interstitial_ad(ad_request: LoadAdRequest)`
	- `load_app_open_ad(ad_request: LoadAdRequest, auto_show_on_resume: boolean)`
- the `Admob` node will emit the following signals once ads have been loaded or failed to load:
	- `banner_ad_loaded(ad_info: AdInfo)`
	- `banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `interstitial_ad_loaded(ad_info: AdInfo)`
	- `interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_ad_loaded(ad_info: AdInfo)`
	- `rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_interstitial_ad_loaded(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `app_open_ad_loaded(ad_info: AdInfo)`
	- `app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- once ads have been loaded, call corresponding `show_*()` method from the `Admob` node with the `ad_id` received:
	- `show_banner_ad(ad_id: String)`
	- `show_interstitial_ad(ad_id: String)`
	- `show_rewarded_ad(ad_id: String)`
	- `show_rewarded_interstitial_ad(ad_id: String)`
	- `show_app_open_ad()`

---

<a name="signals"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Signals
- register listeners for one or more of the following signals of the `Admob` node:
	- `initialization_completed(status_data: InitializationStatus)`
	- `banner_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)`
	- `banner_ad_clicked(ad_info: AdInfo)`
	- `banner_ad_impression(ad_info: AdInfo)`
	- `banner_ad_opened(ad_info: AdInfo)`
	- `banner_ad_closed(ad_info: AdInfo)`
	- `interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `interstitial_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)`
	- `interstitial_ad_impression(ad_info: AdInfo)`
	- `interstitial_ad_clicked(ad_info: AdInfo)`
	- `interstitial_ad_showed_full_screen_content(ad_info: AdInfo)`
	- `interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
	- `interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)`
	- `rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_ad_impression(ad_info: AdInfo)`
	- `rewarded_ad_clicked(ad_info: AdInfo)`
	- `rewarded_ad_showed_full_screen_content(ad_info: AdInfo)`
	- `rewarded_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
	- `rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo)`
	- `rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)`
	- `rewarded_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_interstitial_ad_impression(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_clicked(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_showed_full_screen_content(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
	- `rewarded_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)`
	- `app_open_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `app_open_ad_impression(ad_info: AdInfo)`
	- `app_open_ad_clicked(ad_info: AdInfo)`
	- `app_open_ad_showed_full_screen_content(ad_info: AdInfo)`
	- `app_open_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
	- `native_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
	- `native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `native_ad_impression(ad_info: AdInfo)`
	- `native_ad_size_measured(ad_info: AdInfo)`
	- `native_ad_clicked(ad_info: AdInfo)`
	- `native_ad_swipe_gesture_clicked(ad_info: AdInfo)`
	- `native_ad_opened(ad_info: AdInfo)`
	- `native_ad_closed(ad_info: AdInfo)`
	- `app_open_ad_dismissed_full_screen_content(ad_info: AdInfo)`
	- `consent_form_loaded`
	- `consent_form_dismissed(error_data: FormError)`
	- `consent_form_failed_to_load(error_data: FormError)`
	- `consent_info_updated`
	- `consent_info_update_failed(error_data: FormError)`

---

<a name="methods"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Methods
- `initialize()` - initialize plugin
- `set_request_configuration(AdmobConfig)` - set general configuration that is applied to all ad requests
- `get_initialization_status()` - get initialization status of enabled mediation networks
- `get_global_settings() -> AdmobSettings` - get global ad settings such as ad volume level and whether ads are muted
- `set_global_settings(AdmobSettings)` - set global ad settings such as ad volume level and whether ads are muted. The settings will only apply to ads that are loaded after this method has been called.
- `get_current_adaptive_banner_size()` - get an AdSize with the given width and a Google-optimized height to create a banner ad in current orientation
- `get_portrait_adaptive_banner_size()` - get an AdSize with the given width and a Google-optimized height to create a banner ad in portrait orientation
- `get_landscape_adaptive_banner_size()` - get an AdSize with the given width and a Google-optimized height to create a banner ad in landscape orientation
- `load_banner_ad(ad_request: LoadAdRequest)` - load a banner ad that matches the request parameters
- `show_banner_ad(ad_id: String)` - show the banner ad with given ID
- `hide_banner_ad(ad_id: String)` - hide the banner ad with given ID
- `remove_banner_ad(ad_id: String)` - remove the banner ad with given ID
- `get_banner_dimension(ad_id: String) -> Vector2` - get the size of the banner ad in points
- `get_banner_dimension_in_pixels(ad_id: String) -> Vector2` - get the size of the banner ad in pixels
- `load_interstitial_ad(ad_request: LoadAdRequest)` - load an interstitial ad that matches the request parameters
- `show_interstitial_ad(ad_id: String)` - show the interstitial ad with given ID
- `remove_interstitial_ad(ad_id: String)` - remove the interstitial ad with given ID
- `load_rewarded_ad(ad_request: LoadAdRequest)` - load a rewarded video ad that matches the request parameters
- `show_rewarded_ad(ad_id: String)` - show the rewarded ad with given ID
- `remove_rewarded_ad(ad_id: String)` - remove the rewarded ad with given ID
- `load_rewarded_interstitial_ad()` - load a rewarded interstitial ad that matches the request parameters
- `show_rewarded_interstitial_ad(ad_id: String)` - show the rewarded interstitial ad with given ID
- `remove_rewarded_interstitial_ad(ad_id: String)` - remove the rewarded interstitial ad with given ID
- `load_app_open_ad(ad_request: LoadAdRequest, bool)` - load an app open ad that matches the request parameters
- `show_app_open_ad()` - show loaded app open ad
- `is_app_open_ad_available()` - true if a loaded app open ad exists in cache
- `load_native_ad(a_request: LoadAdRequest)` -  load an native ad that matches the request parameters
- `is_native_ad_loaded() -> bool` - true if a native ad exists in plugin cache
- `show_native_ad(a_ad_id: String)` - show the interstitial ad with given ID
- `hide_native_ad(a_ad_id: String)` - hide the interstitial ad with given ID
- `remove_native_ad(a_ad_id: String)` - remove the interstitial ad with given ID
- `attach_native_ad_to_control(ad_id: String, control: Control)` - attach the native ad with given ID to the specified Control node
- `detach_native_ad(ad_id: String)` - detach the native ad with given ID from the Control node that it is attached
- `load_consent_form()` - load the configured user data privacy consent form
- `show_consent_form()` - show loaded user data privacy consent form
- `get_consent_status() -> UserConsent` - get the status of user's privacy consent
- `is_consent_form_available()` - true if the user consent form has been loaded
- `update_consent_info(a_parameters: ConsentRequestParameters)` - update user consent parameters
- `reset_consent_info()` - reset the user's privacy consent status
- `set_mediation_privacy_settings(NetworkPrivacySettings)` - set privacy settings for enabled ad mediation networks
- `open_app_settings()` - open the system dialog for app-specific settings

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> iOS-only Methods
- `request_tracking_authorization()` - display App Tracking Transparency (ATT) dialog
- `set_app_pause_on_background()` - set the configurable option (default: disabled) that controls whether the Godot engine should simulate an "app lost focus" state when full-screen ads are displayed

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Helper Methods
- `create_request_configuration() -> AdmobConfig` - creates a `AdmobConfig` object populated with the ad configuration from the `Admob` node.
- `create_banner_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the banner ad configuration from the `Admob` node.
- `create_interstitial_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the insterstitial ad configuration from the `Admob` node.
- `create_rewarded_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the rewarded ad configuration from the `Admob` node.
- `create_rewarded_interstitial_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the rewarded interstitial ad configuration from the `Admob` node.

---

<a name="classes"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Classes

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdapterResponseInfo
- Encapsulates adapter response data that is returned by the SDK for an ad request.
- Properties: `ad_error`, `ad_source_id`, `ad_source_instance_id`, `ad_source_instance_name`, `ad_source_name`, `adapter_class_name`, `network_tag`, `latency`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdapterStatus
- Encapsulates adapter status data that is returned by the SDK after initialization or status request.
- Properties: `adapter_class`, `latency`, `initialization_state`, `description`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdError
- Encapsulates error data that is returned by the SDK if an ad fails to display or in other scenarios.
- Properties: `code`, `domain`, `message`, `cause`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdmobAdSize
- Encapsulates ad size data returned by the SDK.
- Properties: `width`, `height`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdmobConfig
- Encapsulates general configuration data that is applied to all ad requests.
- Properties: `is_real`, `max_ad_content_rating`, `tag_for_child_directed_treatment`, `tag_for_under_age_of_consent`, `first_party_id_enabled`, `personalization_state`, `test_device_ids`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> AdmobSettings
- Encapsulates global settings that are applied to all ads loaded after the values have been set.
- Properties:
	- `ad_volume`: Global volume level for all ads
	- `ads_muted`: Whether or not ads are muted
	- `apply_at_startup`: Whether or not the global settings will be reapplied at startup

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> ConsentInformation
- Contains consent status values.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> ConsentRequestParameters
- Encapsulates consent request data that is sent when requesting users' consent for data collection.
- Properties: `is_real`, `tag_for_under_age_of_consent`, `debug_geography`, `test_device_hashed_ids`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> FormError
- Encapsulates error data that is returned by the SDK if an ad fails to load or display a consent form.
- Properties: `code`, `message`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> InitializationStatus
- Contains a dictionary of `AdapterStatus` objects.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> LoadAdError
- Encapsulates error data that is returned by the SDK if an ad fails to load.
- Properties: `code`, `domain`, `message`, `cause`, `response_info`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> LoadAdRequest
- Encapsulates data that defines a request for an ad.
- Properties: `ad_unit_id`, `request_agent`, `ad_size`, `ad_position`, `keywords`, `user_id`, `collapsible_position`, `anchor_to_safe_area`, `custom_data`, `network_extras`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> MediationNetwork
- Encapsulates data that defines an ad mediation network.
- Properties: `flag`, `tag`, `dependencies`, `maven_repo`, `pod`, `pod_version`, `sk_ad_network_ids`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> NetworkExtras
- Encapsulates data that facilitates setting of extra properties required by an ad mediation network.
- Properties: `network_tag`, `extras`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> NetworkPrivacySettings
- Encapsulates data that represents a user's privacy settings.
- Properties: `has_gdpr_consent`, `is_age_restricted_user`, `has_ccpa_sale_consent`, `enabled_networks`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> ResponseInfo
- Encapsulates data that defines the response for an ad request.
- Properties: `adapter_responses`, `loaded_adapter_response`, `adapter_class_name`, `network_tag`, `response_id`

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> RewardItem
- Encapsulates data that defines the received reward from a rewarded ad.
- Properties: `amount`, `type`

---

<a name="nodes"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Nodes

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> InlıneAdaptiveBanner

`InlıneAdaptiveBanner` is a custom Godot node that provides support for loading and showing AdMob inline adaptive banners. Place it inside a Godot Container node such as the `ScrollContainer` and set its `ad_unit_id` and `custom_minimum_size.x` properties.

**Properties:**
- `ad_unit_id` - Ad unit ID of the inline adaptive banner ad to be loaded.
- `max_ad_height` - Maximum pixel height of the requested ad. If set to -1, height will be determined automatically.
- `clip_threshold` - Minimum portion of the banner’s area (as a percentage) that must be clipped before the banner is considered hidden.
- `resize_threshold` - Width-change threshold (in pixels) that triggers a banner reload when the ad container is resized by this amount or more.
- `admob_path` - Path to `Admob` node. Alternatively, the `initialize()` method can be used to provide a reference to the `Admob` node.

**Methods:**
- `initialize(admob_node)` - An alternative to initializing with the `admob_path` property.

---

<a name="banner-ads"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Banner Ads
Banner ads can be categorized as:

- Adaptive Banner Ads
- Fixed-size Banner Ads
- Collapsible Banner Ads

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Banner Position
Banner position can be set to the following values:

- TOP
- BOTTOM
- LEFT
- RIGHT
- TOP-LEFT
- TOP-RIGHT
- BOTTOM-LEFT
- BOTTOM-RIGHT
- CENTER

_Note: Use `LoadAdRequest`'s `set_anchor_to_safe_area` method to position banner ads within the device’s safe area, leaving space at the top or bottom to avoid UI elements such as notches, rounded corners, and home indicator bars. When set to `false`, the banner will be anchored directly to the top or bottom edge of the screen, ignoring safe area insets._

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Banner Size
- The following methods return the size of a Banner ad:
	- `get_banner_dimension()`
	- `get_banner_dimension_in_pixels()`
- These methods are not supported for `FLUID` sized ads. For banner ads of size `FLUID`, the `get_banner_dimension()` method will return `(-3, -4)` and the `get_banner_dimension_in_pixels()` method will return `(-1, -1)`.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Collapsible Banner Ads
Collapsible banner ads are banner ads that are initially presented as a larger overlay with a button to collapse them to their originally-requested banner size. Collapsible banner ads can be requested by setting the `collapsible position` value to `TOP` or `BOTTOM`.

**Note that if `collapsible position` value is in conflict with the [`banner position`](#banner-position) value, then the collapsible banner ad may not function as intended. Set `banner position` and `collapsible position` to the same value for the best experience.**

---

<a name="app-open-ads"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> App Open Ads
App open ads are a special ad format intended for publishers wishing to monetize their app load screens. App open ads can be closed at any time, and are designed to be shown at startup or when your users bring your app to the foreground.

Set `auto_show_on_resume` to `true` in order to show app open ads when users resume (bring from background to foreground) your app. The app open ad should be loaded via the `load_app_open_ad()` method before it can be displayed at startup or upon resumption. Ideally, invoke the `load_app_open_ad()` method at startup and, if `auto_show_on_resume` is enabled, upon each `app_open_ad_impression` signal.

---

<a name="user-consent"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> User Consent
The consent status indicates that the user has been presented with the consent form and has submitted a choice (either consent or withhold consent), making the consent information available for use. It does not indicate that the user has specifically consented to personalized ads — only that consent information has been obtained. Therefore, the plugin will return a status of "OBTAINED" even when the user selects "Do Not Consent" on the consent form.

The UMP SDK handles propagation of the user's actual consent choice to the Google Mobile Ads SDK automatically. Ad requests made after consent is obtained will respect the user's selection (e.g., non-personalized ads if they did not consent).

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> User Consent Methods

- `get_consent_status()` - Returns a consent status value defined in `ConsentInformation.gd`
- `update_consent_info(params: ConsentRequestParameters)` - To be called if `get_consent_status()` returns status UNKNOWN.
- `reset_consent_info()` - To be used only when testing and debugging your application.
- `is_consent_form_available()`
- `load_consent_form()` - To be called if `get_consent_status()` returns status REQUIRED and `is_consent_form_available()` returns `false`.
- `show_consent_form()` - To be called after `consent_form_loaded` signal has been emitted or `is_consent_form_available()` returns `true`.


### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Testing User Consent Logic
In order to test user consent logic for your app, you need to add your test device's hashed identifier to the `test_device_hashed_ids` array of your `Admob` node (or set it programmatically). If you don't know your test device hashed identifier, then run your app with `is_real` set to `false` and look for a log entry such as the following that is logged on iOS.

```
<UMP SDK> To enable debug mode for this device, set: UMPDebugSettings.testDeviceIdentifiers = @[ @"76E885D5-7ACF-4EA8-9B2D-CD8DABB21A1B" ];
```

---

<a name="multi-scene-projects"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Multi-scene projects

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

---

<a name="mediation"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Mediation

Admob Plugin's mediation feature allows selection of up to 15 additional ad mediation networks to serve your ads. For efficiency, <u>**the plugin will only add the SDKs of enabled networks**</u> to your app.

Admob Plugin makes the following ad networks available:

- Google AdMob (enabled by default)
- AppLovin
- Chartboost
- DT Exchange
- i-mobile
- InMobi
- ironSource
- Liftoff Monetize
- LINE Ads Network
- maio
- Meta Audience Network
- Mintegral
- Moloco
- myTarget
- Pangle
- Unity Ads

The networks that you choose will also need to be enabled via your AdMob Console for them to be available to your app.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Network Extras
The network extras that are entered on the `Admob` node will be automatically applied to enabled ad mediation networks.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Network Privacy Settings
Use the `set_mediation_privacy_settings(NetworkPrivacySettings)` method to set the privacy settings for enabled ad mediation networks.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Mediation Results
Each ad-loaded signal includes a `ResponseInfo` object. Check it to view how every enabled ad network responded to the request.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Initialization Status
The `initialization_completed` signal includes an `InitializationStatus` object. Check it to view the initialization status of every enabled ad network. Additionally, the `get_initialization_status()` method also returns the `InitializationStatus` object.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="16"> Mediation Network Configuration
Links to documentation pages and dashboards:

| Network | Android | iOS | 🖥 |
| :--- | :---: | :---: | :---: |
| Applovin | [Config](https://developers.google.com/admob/android/mediation/applovin) | [Config](https://developers.google.com/admob/ios/mediation/applovin) | [Dashboard](https://dash.applovin.com/signup) |
| Chartboost | [Config](https://developers.google.com/admob/android/mediation/chartboost) | [Config](https://developers.google.com/admob/ios/mediation/chartboost) | [Dashboard](https://platform.chartboost.com/signup) |
| DT Exchange | [Config](https://developers.google.com/admob/android/mediation/dt-exchange) | [Config](https://developers.google.com/admob/ios/mediation/dt-exchange) | [Dashboard](https://console.fyber.com/sign-up) |
| i-mobile | [Config](https://developers.google.com/admob/android/mediation/imobile) | [Config](https://developers.google.com/admob/ios/mediation/imobile) | [Dashboard](https://www2.i-mobile.co.jp/pre_register_partner.aspx) |
| InMobi | [Config](https://developers.google.com/admob/android/mediation/inmobi) | [Config](https://developers.google.com/admob/ios/mediation/inmobi) | [Dashboard](https://publisher.inmobi.com/signup) |
| ironSource | [Config](https://developers.google.com/admob/android/mediation/ironsource) | [Config](https://developers.google.com/admob/ios/mediation/ironsource) | [Dashboard](https://platform.ironsrc.com/partners/identity/signup) |
| Liftoff Monetize | [Config](https://developers.google.com/admob/android/mediation/liftoff-monetize) | [Config](https://developers.google.com/admob/ios/mediation/liftoff-monetize) | [Dashboard](https://publisher.vungle.com/applications) |
| LINE Ads Network | [Config](https://developers.google.com/admob/android/mediation/line) | [Config](https://developers.google.com/admob/ios/mediation/line) | [Dashboard](https://pages.linebiz.com/line-ads-network/) |
| maio | [Config](https://developers.google.com/admob/android/mediation/maio) | [Config](https://developers.google.com/admob/ios/mediation/maio) | [Dashboard](https://maio.jp/publisher/login) |
| Meta Audience Network | [Config](https://developers.google.com/admob/android/mediation/meta) | [Config](https://developers.google.com/admob/ios/mediation/meta) | [Dashboard](https://business.facebook.com/pub/start) |
| Mintegral | [Config](https://developers.google.com/admob/android/mediation/mintegral) | [Config](https://developers.google.com/admob/ios/mediation/mintegral) | [Dashboard](https://dev.mintegral.com/user/signup) |
| Moloco | [Config](https://developers.google.com/admob/android/mediation/moloco) | [Config](https://developers.google.com/admob/ios/mediation/moloco) | [Dashboard](https://publisher.moloco.cloud/login) |
| myTarget | [Config](https://developers.google.com/admob/android/mediation/mytarget) | [Config](https://developers.google.com/admob/ios/mediation/mytarget) | [Dashboard](https://target.vk.ru/) |
| Pangle | [Config](https://developers.google.com/admob/android/mediation/pangle) | [Config](https://developers.google.com/admob/ios/mediation/pangle) | [Dashboard](https://pangleglobal.com/media/register) |
| Unity Ads | [Config](https://developers.google.com/admob/android/mediation/unity) | [Config](https://developers.google.com/admob/ios/mediation/unity) | [Dashboard](https://cloud.unity.com/home/) |

---

<a name="export"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Export
Both `Android` and `iOS` exports require several configuration settings.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> File-based Export Configuration
In order to enable file-based export configuration, an `android_export.cfg` or an `ios_export.cfg` file should be placed in the `addons/AdmobPlugin` directory with the file contents formatted as in the example below:

```
[General]
is_real = false

[Debug]
app_id = "ca-app-pub-3940256099942544~3347511713"

[Release]
app_id = "ca-app-pub-3940256099942544~3347511713"

[Mediation]
enabled_networks = ["applovin", "unity"]
```

The `ios_export.cfg` file supports the following additional properties, which are not relevant for Android.

```
[ATT]
att_enabled = true
att_text = "My ATT text."
```

The `is_real` and `app_id` configuration items are mandatory and if not found in the `export.cfg` file, then the plugin will fall back to node-based configuration.

### <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Node-based Export Configuration
If `<platform>_export.cfg` file is not found for the target platform or file-based configuration fails, then the plugin will attempt to load node-based configuration.

During export, the plugin searches for an `Admob` node in the following order:
1. Search the selected scene that is open in the Godot Editor
2. If not found, then search for an `Admob` node in the scene that is configured as the project's main scene in the `Project Settings`
3. If still not found, then the plugin searches all scenes within the project.

If an `Admob` node is not found, then the app will fail due to missing AdMob application identifier.

Therefore; make sure that at least one `Admob` node is present in any one of the scenes in your Godot project.

---

<a name="platform-specific-notes"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Platform-Specific Notes

### Android
- Download Android export template and enable gradle build from export settings
- **Missing APP ID:**
- If your game crashes due to missing APP ID, then make sure that you
	- enter your Admob APP ID in the Admob node and pay attention to the [Android Export section](#android-export).
	- or enter it in the `android_export.cfg` file as described in the [File-based Export](#export) section.
- **Troubleshooting:**
- Logs: `adb logcat | grep 'godot'` (Linux), `adb.exe logcat | select-string "godot"` (Windows)
- You may find the following resources helpful:
	- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
	- https://developer.android.com/tools/adb
	- https://developer.android.com/studio/debug
	- https://developer.android.com/courses

### iOS
- Follow instructions on [Exporting for iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
- **Mediation**: if you have enabled mediation networks, after exporting your project to iOS, open the generated `.xcworkspace`on Xcode (not `.xcodeproj`!)
- **Missing APP ID** crashes: make sure that you
	- enter your Admob APP ID in the Admob node and pay attention to the [iOS Export section](#ios-export).
	- or enter it in the `android_export.cfg` file as described in the [File-based Export](#export) section.
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

---

<a name="general-troubleshooting"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> General Troubleshooting

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Ad Blockers

Ad blockers can prevent AdMob from loading ad resources, block network calls to Google’s ad servers, or hide rendered ad views, which results in missing impressions, zero-fill rates, or seemingly “stuck” loading states. Because these failures happen outside your app’s control, AdMob won’t report clear errors. Potential blocking can be detected by checking for repeated load failures with no error codes, monitoring network logs for blocked Google ad domains, or prompting users to disable known system-wide blockers (VPN-based, DNS-based) when ads consistently fail. In production, the only reliable remedy is asking users to whitelist the app or disable the blocking service.

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> DNS Settings

DNS settings can affect AdMob by causing ad-request failures if the device or network cannot properly resolve the domains used by Google’s ad and consent services. Misconfigured DNS (including privacy-filtered DNS or restrictive enterprise DNS) may block or misroute requests, leading to missing ads, slow loads, or consent-flow errors. Issues can be detected by checking device logs for failed hostname resolutions, testing with a different DNS provider (e.g., Google Public DNS or the ISP’s default), or trying another network to confirm whether DNS is the cause. To remedy problems, users should switch to a reliable DNS provider, disable overly aggressive filtering, ensure required Google domains are allowed, and verify that VPNs or DNS-based firewalls aren’t interfering with ad traffic.

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Regional Restrictions

AdMob is not available everywhere. A list of restricted countries and regions can be found at the link below.

- [Regional Restrictions](https://support.google.com/admob/answer/6163675?hl=en)

---

<a name="video-tutorials"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Video Tutorials

## **Admob Plugin on Android** -- _by [16BitDev](https://www.youtube.com/@16bitdev)_
[![Admob Plugin on Android](https://img.youtube.com/vi/V9_Gpy0R3RE/0.jpg)](https://www.youtube.com/watch?v=V9_Gpy0R3RE)

## **Consent Management with the Admob Plugin** -- _by [Code Artist](https://www.youtube.com/@codeartist1687)_
[![Consent Management with the Admob Plugin](https://img.youtube.com/vi/MrLcPdoH-yU/0.jpg)](https://www.youtube.com/watch?v=MrLcPdoH-yU)

## **Admob Plugin on Android** -- _by [Code Artist](https://www.youtube.com/@codeartist1687)_
[![Admob Plugin on Android](https://img.youtube.com/vi/K13xFyOYySk/0.jpg)](https://www.youtube.com/watch?v=K13xFyOYySk)

---

<a name="links"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Links

- [AssetLib Entry Android](https://godotengine.org/asset-library/asset/2548)
- [AssetLib Entry iOS](https://godotengine.org/asset-library/asset/3178)

---

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> All Plugins

| Plugin | Android | iOS | Free | Open Source | License |
| :--- | :---: | :---: | :---: | :---: | :---: |
| [Admob](https://github.com/godot-sdk-integrations/godot-admob) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Notification Scheduler](https://github.com/godot-mobile-plugins/godot-notification-scheduler) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Deeplink](https://github.com/godot-mobile-plugins/godot-deeplink) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Share](https://github.com/godot-mobile-plugins/godot-share) | ✅ | ✅ | ✅ | ✅ | MIT |
| [In-App Review](https://github.com/godot-mobile-plugins/godot-inapp-review) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Native Camera](https://github.com/godot-mobile-plugins/godot-native-camera) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Connection State](https://github.com/godot-mobile-plugins/godot-connection-state) | ✅ | ✅ | ✅ | ✅ | MIT |
| [OAuth 2.0](https://github.com/godot-mobile-plugins/godot-oauth2) | ✅ | ✅ | ✅ | ✅ | MIT |
| [QR](https://github.com/godot-mobile-plugins/godot-qr) | ✅ | ✅ | ✅ | ✅ | MIT |
| [Firebase](https://github.com/godot-mobile-plugins/godot-firebase) | ✅ | ✅ | ✅ | ✅ | MIT |

---

<a name="credits"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Credits

Developed by [Cengiz](https://github.com/cengiz-pz)

Based on [Godot Mobile Plugin Template](https://github.com/godot-mobile-plugins/godot-plugin-template)

Original repository: [Godot Admob Plugin](https://github.com/godot-sdk-integrations/godot-admob)

---

<a name="contributing"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Contributing

See [our guide](https://github.com/godot-sdk-integrations/godot-admob?tab=contributing-ov-file) if you would like to contribute to this project.

---

# 💖 Support the Project

If this plugin has helped you, consider supporting its development! Every bit of support helps keep the plugin updated and bug-free.

| | Ways to Help | How to do it |
| :--- | :--- | :--- |
|✨⭐| **Spread the Word** | [Star this repo](https://github.com/godot-sdk-integrations/godot-admob/stargazers) to help others find it. |
|💡✨| **Give Feedback** | [Open an issue](https://github.com/godot-sdk-integrations/godot-admob/issues) or [suggest a feature](https://github.com/godot-sdk-integrations/godot-admob/issues/new). |
|🧩| **Contribute** | [Submit a PR](https://github.com/godot-sdk-integrations/godot-admob?tab=contributing-ov-file) to help improve the codebase. |
|❤️| **Buy a Coffee** | Support the maintainers on GitHub Sponsors or other platforms. |

## ⭐ Star History
[![Star History Chart](https://api.star-history.com/svg?repos=godot-sdk-integrations/godot-admob&type=Date)](https://star-history.com/#godot-sdk-integrations/godot-admob&Date)
