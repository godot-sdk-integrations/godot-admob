---
title: Methods
---

# <img src="../images/icon.png" width="20"> Methods

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

## <img src="../images/icon.png" width="16"> iOS-only Methods

- `request_tracking_authorization()` - display App Tracking Transparency (ATT) dialog
- `set_app_pause_on_background()` - set the configurable option (default: disabled) that controls whether the Godot engine should simulate an "app lost focus" state when full-screen ads are displayed

## <img src="../images/icon.png" width="16"> Helper Methods

- `create_request_configuration() -> AdmobConfig` - creates a `AdmobConfig` object populated with the ad configuration from the `Admob` node.
- `create_banner_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the banner ad configuration from the `Admob` node.
- `create_interstitial_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the insterstitial ad configuration from the `Admob` node.
- `create_rewarded_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the rewarded ad configuration from the `Admob` node.
- `create_rewarded_interstitial_ad_request() -> LoadAdRequest` - creates a `LoadAdRequest` object populated with the rewarded interstitial ad configuration from the `Admob` node.