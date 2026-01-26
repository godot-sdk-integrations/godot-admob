#
# © 2024-present https://github.com/cengiz-pz
#

@tool
class_name Admob extends Node

signal initialization_completed(status_data: InitializationStatus)
signal banner_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)
signal banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)
signal banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)
signal banner_ad_impression(ad_info: AdInfo)
signal banner_ad_size_measured(ad_info: AdInfo)
signal banner_ad_clicked(ad_info: AdInfo)
signal banner_ad_opened(ad_info: AdInfo)
signal banner_ad_closed(ad_info: AdInfo)
signal interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)
signal interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)
signal interstitial_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)
signal interstitial_ad_impression(ad_info: AdInfo)
signal interstitial_ad_clicked(ad_info: AdInfo)
signal interstitial_ad_showed_full_screen_content(ad_info: AdInfo)
signal interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)
signal interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)
signal rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)
signal rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)
signal rewarded_ad_impression(ad_info: AdInfo)
signal rewarded_ad_clicked(ad_info: AdInfo)
signal rewarded_ad_showed_full_screen_content(ad_info: AdInfo)
signal rewarded_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)
signal rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo)
signal rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)
signal rewarded_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)
signal rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)
signal rewarded_interstitial_ad_impression(ad_info: AdInfo)
signal rewarded_interstitial_ad_clicked(ad_info: AdInfo)
signal rewarded_interstitial_ad_showed_full_screen_content(ad_info: AdInfo)
signal rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)
signal rewarded_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)
signal rewarded_interstitial_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)
signal app_open_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)
signal app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)
signal app_open_ad_impression(ad_info: AdInfo)
signal app_open_ad_clicked(ad_info: AdInfo)
signal app_open_ad_showed_full_screen_content(ad_info: AdInfo)
signal app_open_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)
signal app_open_ad_dismissed_full_screen_content(ad_info: AdInfo)
signal native_ad_loaded(ad_data, response)
signal native_ad_failed_to_load(ad_data, error)
signal native_ad_impression(ad_data)
signal native_ad_size_measured(ad_data)
signal native_ad_clicked(ad_data)
signal native_ad_swipe_gesture_clicked(ad_data)
signal native_ad_opened(ad_data)
signal native_ad_closed(ad_data)
signal consent_form_loaded
signal consent_form_dismissed(error_data: FormError)
signal consent_form_failed_to_load(error_data: FormError)
signal consent_info_updated
signal consent_info_update_failed(error_data: FormError)
signal tracking_authorization_granted
signal tracking_authorization_denied

const PLUGIN_SINGLETON_NAME: String = "@pluginName@"

const ANDROID_BANNER_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/2014213617"
const ANDROID_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1033173712"
const ANDROID_REWARDED_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"
const ANDROID_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5354046379"
const ANDROID_APP_OPEN_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/9257395921"
const ANDROID_NATIVE_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/2247696110"

const IOS_BANNER_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/8388050270"
const IOS_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/4411468910"
const IOS_REWARDED_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1712485313"
const IOS_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6978759866"
const IOS_APP_OPEN_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5575463023"
const IOS_NATIVE_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/3986624511"

const MINIMUM_CACHE_SIZE: int = 1
const MAXIMUM_CACHE_SIZE: int = 1000

@export_category("General")
## The plugin will use real app and ad IDs if true; debug IDs will be used otherwise.
@export var is_real: bool: set = set_is_real

## Setting used by publishers in Google's advertising platforms to specify the maximum content maturity level for the ads allowed to be served in their apps.
@export var max_ad_content_rating: AdmobConfig.ContentRating = AdmobConfig.ContentRating.G: set = set_max_ad_content_rating

## TFCD is a parameter that publishers and app developers use to indicate to Google that their content should be treated as child-directed for the purposes of
## the Children's Online Privacy Protection Act (COPPA).
@export var child_directed: AdmobConfig.TagForChildDirectedTreatment = AdmobConfig.TagForChildDirectedTreatment.UNSPECIFIED: set = set_child_directed

## TFUA is a technical parameter to indicate that a user is under the digital age of consent in the European Economic Area (EEA), the UK, and Switzerland.
@export var under_age_of_consent: AdmobConfig.TagForUnderAgeOfConsent = AdmobConfig.TagForUnderAgeOfConsent.UNSPECIFIED: set = set_under_age_of_consent

## A configuration option that controls the use of first-party IDs for tracking user interactions.
@export var first_party_id_enabled: bool = true: set = set_first_party_id_enabled

## A parameter used to determine whether a user can receive personalized ads, non-personalized ads, or limited ads based on their consent choices.
@export var personalization_state: AdmobConfig.PersonalizationState = AdmobConfig.PersonalizationState.DEFAULT: set = set_personalization_state

## A string used to identify the origin of an ad request when a third-party library or platform is used to mediate requests to the Google Mobile Ads SDK.
@export var request_agent: String = PLUGIN_SINGLETON_NAME: set = set_request_agent

## Whether the plugin should automatically apply the configuration after initialization has been completed.
@export var auto_configure_on_initialize: bool = true

@export_group("Global Settings", "global_")

## Sets the ads' audio volume. Minimum value is 0.0 and maximum value is 1.0.
@export_range(0.0, 1.0, 0.01) var global_ad_volume: float = 1.0

## Whether or not the ads' audio will be muted.
@export var global_ads_muted: bool = false

## Whether or not the global settings will be reapplied at app restart.
@export var global_apply_at_startup: bool = false


@export_category("Ad Type-specific")
@export_group("Banner", "banner_")
## Part of the screen where the banner ad will be anchored at.
@export var banner_position: LoadAdRequest.AdPosition = LoadAdRequest.AdPosition.TOP: set = set_banner_position

## The size of the banner ad.
@export var banner_size: LoadAdRequest.RequestedAdSize = LoadAdRequest.RequestedAdSize.BANNER: set = set_banner_size

## If not set to disabled, then specifies the direction towards which the banner ad will collapse.
@export var banner_collapsible_position: LoadAdRequest.CollapsiblePosition = LoadAdRequest.CollapsiblePosition.DISABLED: set = set_banner_collapsible_position

## When enabled, the banner ad will be positioned within the device’s safe area, leaving space at the top or bottom to avoid UI elements
## such as notches, rounded corners, and home indicator bars. When disabled, the banner will be anchored directly to the top or bottom edge
## of the screen, ignoring safe area insets.
@export var banner_anchor_to_safe_area: bool = false


@export_group("App Open")
## Specifies whether app open ad will be displayed when users return the app to the foreground state.
@export var auto_show_on_resume: bool = false: set = set_auto_show_on_resume


@export_category("Android-specific")
@export_group("Android Application IDs","android_")
## Specifies the AdMob application ID used when testing the app on Android.
@export var android_debug_application_id: String = ""

## Specifies the AdMob application ID used after releasing the Android app to production.
@export var android_real_application_id: String = ""


@export_group("Android Debug Ad Unit IDs", "android_debug_")
## Specifies the AdMob banner ad ID used when testing the app on Android.
@export var android_debug_banner_id: String = ANDROID_BANNER_DEMO_AD_UNIT_ID

## Specifies the AdMob interstitial ad ID used when testing the app on Android.
@export var android_debug_interstitial_id: String = ANDROID_INTERSTITIAL_DEMO_AD_UNIT_ID

## Specifies the AdMob rewarded ad ID used when testing the app on Android.
@export var android_debug_rewarded_id: String = ANDROID_REWARDED_DEMO_AD_UNIT_ID

## Specifies the AdMob rewarded-interstitial ad ID used when testing the app on Android.
@export var android_debug_rewarded_interstitial_id: String = ANDROID_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID

## Specifies the AdMob app open ad ID used when testing the app on Android.
@export var android_debug_app_open_id: String = ANDROID_APP_OPEN_DEMO_AD_UNIT_ID

## Specifies the AdMob native ad ID used when testing the app on Android.
@export var android_debug_native_id: String = ANDROID_NATIVE_DEMO_AD_UNIT_ID

@export_group("Android Real Ad Unit IDs", "android_real_")
## Specifies the AdMob banner ad ID used after releasing the Android app to production.
@export var android_real_banner_id: String = ""

## Specifies the AdMob interstitial ad ID used after releasing the Android app to production.
@export var android_real_interstitial_id: String = ""

## Specifies the AdMob rewarded ad ID used after releasing the Android app to production.
@export var android_real_rewarded_id: String = ""

## Specifies the AdMob rewarded-interstitial ad ID used after releasing the Android app to production.
@export var android_real_rewarded_interstitial_id: String = ""

## Specifies the AdMob app open ad ID used after releasing the Android app to production.
@export var android_real_app_open_id: String = ""

## Specifies the AdMob native ad ID used after releasing the Android app to production.
@export var android_real_native_id: String = ""


@export_category("iOS-specific")
@export_group("iOS Application IDs","ios_")
## Specifies the AdMob application ID used when testing the app on iOS.
@export var ios_debug_application_id: String = ""

## Specifies the AdMob application ID used after releasing the iOS app to production.
@export var ios_real_application_id: String = ""


@export_group("iOS Debug Ad Unit IDs", "ios_debug_")
## Specifies the AdMob banner ad ID used when testing the app on iOS.
@export var ios_debug_banner_id: String = IOS_BANNER_DEMO_AD_UNIT_ID

## Specifies the AdMob interstitial ad ID used when testing the app on iOS.
@export var ios_debug_interstitial_id: String = IOS_INTERSTITIAL_DEMO_AD_UNIT_ID

## Specifies the AdMob rewarded ad ID used when testing the app on iOS.
@export var ios_debug_rewarded_id: String = IOS_REWARDED_DEMO_AD_UNIT_ID

## Specifies the AdMob rewarded-interstitial ad ID used when testing the app on iOS.
@export var ios_debug_rewarded_interstitial_id: String = IOS_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID

## Specifies the AdMob app open ad ID used when testing the app on iOS.
@export var ios_debug_app_open_id: String = IOS_APP_OPEN_DEMO_AD_UNIT_ID

## Specifies the AdMob native ad ID used when testing the app on ios.
@export var ios_debug_native_id: String = IOS_NATIVE_DEMO_AD_UNIT_ID


@export_group("iOS Real Ad Unit IDs", "ios_real_")
## Specifies the AdMob banner ad ID used after releasing the iOS app to production.
@export var ios_real_banner_id: String = ""

## Specifies the AdMob interstitial ad ID used after releasing the iOS app to production.
@export var ios_real_interstitial_id: String = ""

## Specifies the AdMob rewarded ad ID used after releasing the iOS app to production.
@export var ios_real_rewarded_id: String = ""

## Specifies the AdMob rewarded-interstitial ad ID used after releasing the iOS app to production.
@export var ios_real_rewarded_interstitial_id: String = ""

## Specifies the AdMob app open ad ID used after releasing the iOS app to production.
@export var ios_real_app_open_id: String = ""

## Specifies the AdMob native ad ID used after releasing the iOS app to production.
@export var ios_real_native_id: String = ""


@export_group("App Tracking Transparency")
## Whether the iOS-specific App Tracking Transparency (ATT) work flow is enabled for the app.
@export var att_enabled: bool = false:
	get:
		return att_enabled
	set(value):
		att_enabled = value

## The iOS-specific custom message explaining why your app is requesting tracking permission, to be displayed within the App Tracking Transparency (ATT) dialog presented to the user.
@export_multiline var att_text: String = "": set = set_att_text


@export_category("Mediation")
@export_group("Networks")
## List of ad networks whose SDKs will be attached to the exported app.
@export_flags(" ") var enabled_networks = 0	# Networks populated in _validate_property() function


@export_group("Network Extras")
## Allows passing of additional, network-specific parameters from the app to an ad network's adapter during an ad request.
@export var network_extras: Array[NetworkExtras] = []


@export_category("Cache")
@export_group("Limits")
## Maximum number of banner ads to keep in the cache before removing old ads.
@export_range(MINIMUM_CACHE_SIZE,MAXIMUM_CACHE_SIZE) var max_banner_ad_cache: int = 10: set = set_max_banner_ad_cache

## Maximum number of interstitial ads to keep in the cache before removing old ads.
@export_range(MINIMUM_CACHE_SIZE,MAXIMUM_CACHE_SIZE) var max_interstitial_ad_cache: int = 3: set = set_max_interstitial_ad_cache

## Maximum number of rewarded ads to keep in the cache before removing old ads.
@export_range(MINIMUM_CACHE_SIZE,MAXIMUM_CACHE_SIZE) var max_rewarded_ad_cache: int = 3: set = set_max_rewarded_ad_cache

## Maximum number of rewarded-interstitial ads to keep in the cache before removing old ads.
@export_range(MINIMUM_CACHE_SIZE,MAXIMUM_CACHE_SIZE) var max_rewarded_interstitial_ad_cache: int = 3: set = set_max_rewarded_interstitial_ad_cache

## Maximum number of native ads to keep in the cache before removing old ads.
@export_range(MINIMUM_CACHE_SIZE,MAXIMUM_CACHE_SIZE) var max_native_ad_cache: int = 10: set = set_max_native_ad_cache

@export_group("Cleanup After Ad Displayed") # For single-use ad types. Banner ads are multi-use.
## Cleanup cached interstitial ads after they are displayed. Interstitial ads are single-use.
@export var remove_interstitial_ads_after_displayed: bool = false

## Cleanup cached rewarded ads after they are displayed. Rewarded ads are single-use.
@export var remove_rewarded_ads_after_displayed: bool = true

## Cleanup cached rewarded-interstitial ads after they are displayed. Rewarded-interstitial ads are single-use.
@export var remove_rewarded_interstitial_ads_after_displayed: bool = true


@export_group("Cleanup After Scene Exit")
## Cleanup cached banner ads when the Admob node is destroyed.
@export var remove_banner_ads_after_scene: bool = true

## Cleanup cached interstitial ads when the Admob node is destroyed.
@export var remove_interstitial_ads_after_scene: bool = true

## Cleanup cached rewarded ads when the Admob node is destroyed.
@export var remove_rewarded_ads_after_scene: bool = true

## Cleanup cached rewarded-interstitial ads when the Admob node is destroyed.
@export var remove_rewarded_interstitial_ads_after_scene: bool = true


@export_category("Debug")
@export_group("Settings")
## The user location used when testing the consent management functionality.
@export var debug_geography: ConsentRequestParameters.DebugGeography = ConsentRequestParameters.DebugGeography.NOT_SET : set = set_debug_geography

## A list of SHA-256–hashed device IDs that should be registered as test devices in AdMob.
@export var test_device_hashed_ids: Array[String] = []

var is_initialization_completed: bool

var _banner_id: String
var _interstitial_id: String
var _rewarded_id: String
var _rewarded_interstitial_id: String
var _app_open_id: String
var _native_id: String

var _plugin_singleton: Object

var _active_banner_ads: AdCache
var _active_interstitial_ads: AdCache
var _active_rewarded_ads: AdCache
var _active_rewarded_interstitial_ads: AdCache
var _active_native_ads: AdCache

var _native_control_bindings: Dictionary = {}


func _init() -> void:
	is_initialization_completed = false

	_active_banner_ads = AdCache.new(max_banner_ad_cache, "banner_ad", remove_banner_ad)
	_active_interstitial_ads = AdCache.new(max_interstitial_ad_cache, "interstitial_ad",
			remove_interstitial_ad)
	_active_rewarded_ads = AdCache.new(max_rewarded_ad_cache, "rewarded_ad", remove_rewarded_ad)
	_active_rewarded_interstitial_ads = AdCache.new(max_rewarded_interstitial_ad_cache,
			"rewarded_interstitial_ad", remove_rewarded_interstitial_ad)
	_active_native_ads = AdCache.new(max_native_ad_cache, "native_ad", remove_native_ad)

func _validate_property(property: Dictionary) -> void:
	if property.name == "enabled_networks":
		property.hint_string = ",".join(MediationNetwork.MEDIATION_NETWORK_TAGS.keys())


func _ready() -> void:
	if OS.has_feature("ios"):
		if is_real:
			_banner_id = ios_real_banner_id
			_interstitial_id = ios_real_interstitial_id
			_rewarded_id = ios_real_rewarded_id
			_rewarded_interstitial_id = ios_real_rewarded_interstitial_id
			_app_open_id = ios_real_app_open_id
			_native_id = ios_real_native_id
		else:
			_banner_id = ios_debug_banner_id
			_interstitial_id = ios_debug_interstitial_id
			_rewarded_id = ios_debug_rewarded_id
			_rewarded_interstitial_id = ios_debug_rewarded_interstitial_id
			_app_open_id = ios_debug_app_open_id
			_native_id = ios_debug_native_id
	else:
		if is_real:
			_banner_id = android_real_banner_id
			_interstitial_id = android_real_interstitial_id
			_rewarded_id = android_real_rewarded_id
			_rewarded_interstitial_id = android_real_rewarded_interstitial_id
			_app_open_id = android_real_app_open_id
			_native_id = android_real_native_id
		else:
			_banner_id = android_debug_banner_id
			_interstitial_id = android_debug_interstitial_id
			_rewarded_id = android_debug_rewarded_id
			_rewarded_interstitial_id = android_debug_rewarded_interstitial_id
			_app_open_id = android_debug_app_open_id
			_native_id = android_debug_native_id

	_update_plugin()


func _exit_tree() -> void:
	if _plugin_singleton:
		if remove_banner_ads_after_scene:
			for __ad_id in _active_banner_ads.all_keys():
				remove_banner_ad(__ad_id)

		if remove_interstitial_ads_after_scene:
			for __ad_id in _active_interstitial_ads.all_keys():
				remove_interstitial_ad(__ad_id)

		if remove_rewarded_ads_after_scene:
			for __ad_id in _active_rewarded_ads.all_keys():
				remove_rewarded_ad(__ad_id)

		if remove_rewarded_interstitial_ads_after_scene:
			for __ad_id in _active_rewarded_interstitial_ads.all_keys():
				remove_rewarded_interstitial_ad(__ad_id)


func _notification(a_what: int) -> void:
	if a_what == NOTIFICATION_APPLICATION_RESUMED:
		_update_plugin()


func _update_plugin() -> void:
	if _plugin_singleton == null:
		if Engine.has_singleton(PLUGIN_SINGLETON_NAME):
			_plugin_singleton = Engine.get_singleton(PLUGIN_SINGLETON_NAME)
			_connect_signals()
		elif not OS.has_feature("editor_hint"):
			Admob.log_error("%s singleton not found!" % PLUGIN_SINGLETON_NAME)


func _connect_signals() -> void:
	_plugin_singleton.connect("initialization_completed", _on_initialization_completed)
	_plugin_singleton.connect("banner_ad_loaded", _on_banner_ad_loaded)
	_plugin_singleton.connect("banner_ad_failed_to_load", _on_banner_ad_failed_to_load)
	_plugin_singleton.connect("banner_ad_refreshed", _on_banner_ad_refreshed)
	_plugin_singleton.connect("banner_ad_impression", _on_banner_ad_impression)
	_plugin_singleton.connect("banner_ad_size_measured", _on_banner_ad_size_measured)
	_plugin_singleton.connect("banner_ad_clicked", _on_banner_ad_clicked)
	_plugin_singleton.connect("banner_ad_opened", _on_banner_ad_opened)
	_plugin_singleton.connect("banner_ad_closed", _on_banner_ad_closed)
	_plugin_singleton.connect("interstitial_ad_loaded", _on_interstitial_ad_loaded)
	_plugin_singleton.connect("interstitial_ad_failed_to_load", _on_interstitial_ad_failed_to_load)
	_plugin_singleton.connect("interstitial_ad_refreshed", _on_interstitial_ad_refreshed)
	_plugin_singleton.connect("interstitial_ad_impression", _on_interstitial_ad_impression)
	_plugin_singleton.connect("interstitial_ad_clicked", _on_interstitial_ad_clicked)
	_plugin_singleton.connect("interstitial_ad_showed_full_screen_content", _on_interstitial_ad_showed_full_screen_content)
	_plugin_singleton.connect("interstitial_ad_failed_to_show_full_screen_content", _on_interstitial_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("interstitial_ad_dismissed_full_screen_content", _on_interstitial_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
	_plugin_singleton.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
	_plugin_singleton.connect("rewarded_ad_impression", _on_rewarded_ad_impression)
	_plugin_singleton.connect("rewarded_ad_clicked", _on_rewarded_ad_clicked)
	_plugin_singleton.connect("rewarded_ad_showed_full_screen_content", _on_rewarded_ad_showed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_failed_to_show_full_screen_content", _on_rewarded_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_dismissed_full_screen_content", _on_rewarded_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_user_earned_reward", _on_rewarded_ad_user_earned_reward)
	_plugin_singleton.connect("rewarded_interstitial_ad_loaded", _on_rewarded_interstitial_ad_loaded)
	_plugin_singleton.connect("rewarded_interstitial_ad_failed_to_load", _on_rewarded_interstitial_ad_failed_to_load)
	_plugin_singleton.connect("rewarded_interstitial_ad_impression", _on_rewarded_interstitial_ad_impression)
	_plugin_singleton.connect("rewarded_interstitial_ad_clicked", _on_rewarded_interstitial_ad_clicked)
	_plugin_singleton.connect("rewarded_interstitial_ad_showed_full_screen_content", _on_rewarded_interstitial_ad_showed_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_failed_to_show_full_screen_content", _on_rewarded_interstitial_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_dismissed_full_screen_content", _on_rewarded_interstitial_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_user_earned_reward", _on_rewarded_interstitial_ad_user_earned_reward)
	_plugin_singleton.connect("app_open_ad_loaded", _on_app_open_ad_loaded)
	_plugin_singleton.connect("app_open_ad_failed_to_load", _on_app_open_ad_failed_to_load)
	_plugin_singleton.connect("app_open_ad_impression", _on_app_open_ad_impression)
	_plugin_singleton.connect("app_open_ad_clicked", _on_app_open_ad_clicked)
	_plugin_singleton.connect("app_open_ad_showed_full_screen_content", _on_app_open_ad_showed_full_screen_content)
	_plugin_singleton.connect("app_open_ad_failed_to_show_full_screen_content", _on_app_open_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("app_open_ad_dismissed_full_screen_content", _on_app_open_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("native_ad_loaded", _on_native_ad_loaded)
	_plugin_singleton.connect("native_ad_failed_to_load", _on_native_ad_failed_to_load)
	_plugin_singleton.connect("native_ad_impression", _on_native_ad_impression)
	_plugin_singleton.connect("native_ad_size_measured", _on_native_ad_size_measured)
	_plugin_singleton.connect("native_ad_clicked", _on_native_ad_clicked)
	_plugin_singleton.connect("native_ad_swipe_gesture_clicked", _native_ad_swipe_gesture_clicked)
	_plugin_singleton.connect("native_ad_opened", _on_native_ad_opened)
	_plugin_singleton.connect("native_ad_closed", _on_native_ad_closed)
	_plugin_singleton.connect("consent_form_loaded", _on_consent_form_loaded)
	_plugin_singleton.connect("consent_form_dismissed", _on_consent_form_dismissed)
	_plugin_singleton.connect("consent_form_failed_to_load", _on_consent_form_failed_to_load)
	_plugin_singleton.connect("consent_info_updated", _on_consent_info_updated)
	_plugin_singleton.connect("consent_info_update_failed", _on_consent_info_update_failed)
	if _plugin_singleton.has_signal("tracking_authorization_granted"):
		_plugin_singleton.connect("tracking_authorization_granted", _on_tracking_authorization_granted)
	if _plugin_singleton.has_signal("tracking_authorization_denied"):
		_plugin_singleton.connect("tracking_authorization_denied", _on_tracking_authorization_denied)


func initialize() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.initialize()


func get_initialization_status() -> InitializationStatus:
	var __status: InitializationStatus

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		__status = InitializationStatus.new(_plugin_singleton.get_initialization_status())

	return __status


func set_is_real(a_value: bool) -> void:
	is_real = a_value


func set_max_ad_content_rating(a_value: AdmobConfig.ContentRating) -> void:
	max_ad_content_rating = a_value


func set_child_directed(a_value: AdmobConfig.TagForChildDirectedTreatment) -> void:
	child_directed = a_value


func set_under_age_of_consent(a_value: AdmobConfig.TagForUnderAgeOfConsent) -> void:
	under_age_of_consent = a_value


func set_first_party_id_enabled(a_value: bool) -> void:
	first_party_id_enabled = a_value


func set_personalization_state(a_value: AdmobConfig.PersonalizationState) -> void:
	personalization_state = a_value


func set_request_agent(a_value: String) -> void:
	request_agent = a_value


func set_att_text(a_value: String) -> void:
	att_text = a_value


func set_banner_position(a_value: LoadAdRequest.AdPosition) -> void:
	banner_position = a_value


func set_banner_size(a_value: LoadAdRequest.RequestedAdSize) -> void:
	banner_size = a_value


func set_banner_collapsible_position(a_value: LoadAdRequest.CollapsiblePosition) -> void:
	banner_collapsible_position = a_value


func set_auto_show_on_resume(a_value: bool) -> void:
	auto_show_on_resume = a_value


func set_max_banner_ad_cache(a_value: int) -> void:
	max_banner_ad_cache = clampi(a_value, MINIMUM_CACHE_SIZE, MAXIMUM_CACHE_SIZE)


func set_max_interstitial_ad_cache(a_value: int) -> void:
	max_interstitial_ad_cache = clampi(a_value, MINIMUM_CACHE_SIZE, MAXIMUM_CACHE_SIZE)


func set_max_rewarded_ad_cache(a_value: int) -> void:
	max_rewarded_ad_cache = clampi(a_value, MINIMUM_CACHE_SIZE, MAXIMUM_CACHE_SIZE)


func set_max_rewarded_interstitial_ad_cache(a_value: int) -> void:
	max_rewarded_interstitial_ad_cache = clampi(a_value, MINIMUM_CACHE_SIZE, MAXIMUM_CACHE_SIZE)

func set_max_native_ad_cache(a_value: int) -> void:
	max_native_ad_cache = clampi(a_value, MINIMUM_CACHE_SIZE, MAXIMUM_CACHE_SIZE)

func set_debug_geography(a_value: ConsentRequestParameters.DebugGeography) -> void:
	debug_geography = a_value


func is_mediation_enabled() -> bool:
	return enabled_networks > 0


func create_request_configuration() -> AdmobConfig:
	return (AdmobConfig.new()
			.set_is_real(is_real)
			.set_max_ad_content_rating(max_ad_content_rating)
			.set_child_directed_treatment(child_directed)
			.set_under_age_of_consent(under_age_of_consent)
			.set_first_party_id_enabled(first_party_id_enabled)
			.set_personalization_state(personalization_state))


func set_request_configuration(a_config: AdmobConfig = null) -> void:
	if _plugin_singleton != null:
		if a_config == null:
			a_config = (AdmobConfig.new()
					.set_is_real(is_real)
					.set_max_ad_content_rating(max_ad_content_rating)
					.set_child_directed_treatment(child_directed)
					.set_under_age_of_consent(under_age_of_consent)
					.set_first_party_id_enabled(first_party_id_enabled)
					.set_personalization_state(personalization_state))

		_plugin_singleton.set_request_configuration(a_config.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func set_app_pause_on_background(a_pause: bool) -> void:
	if _plugin_singleton != null:
		_plugin_singleton.set_app_pause_on_background(a_pause)
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func get_global_settings() -> AdmobSettings:
	var __settings: AdmobSettings

	if _plugin_singleton != null:
		__settings = AdmobSettings.new(_plugin_singleton.get_global_settings())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return __settings


func set_global_settings(a_settings: AdmobSettings = null) -> void:
	if _plugin_singleton != null:
		if a_settings == null:
			a_settings = (AdmobSettings.new()
					.set_ad_volume(global_ad_volume)
					.set_ads_muted(global_ads_muted)
					.set_apply_at_startup(global_apply_at_startup))
		_plugin_singleton.set_global_settings(a_settings.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func create_basic_ad_request() -> LoadAdRequest:
	var __request: LoadAdRequest

	__request = LoadAdRequest.new().set_request_agent(request_agent)

	if is_mediation_enabled():
		__request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))

	return __request


func create_banner_ad_request() -> LoadAdRequest:
	return (create_basic_ad_request()
			.set_ad_unit_id(_banner_id)
			.set_ad_position(banner_position)
			.set_ad_size(banner_size)
			.set_collapsible_position(banner_collapsible_position)
			.set_anchor_to_safe_area(banner_anchor_to_safe_area))


func load_banner_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = create_banner_ad_request()
		_plugin_singleton.load_banner_ad(a_request.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_banner_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_banner_ads.is_empty() == false
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot show banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.show_banner_ad(_active_banner_ads.last_key())	# show last ad to load
		else:
			if _active_banner_ads.has_key(a_ad_id):
				_plugin_singleton.show_banner_ad(a_ad_id)
			else:
				Admob.log_error("Cannot show banner. Ad with ID '%s' not found." % a_ad_id)


func hide_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot hide banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.hide_banner_ad(_active_banner_ads.last_key())	# hide last ad to load
		else:
			if _active_banner_ads.has_key(a_ad_id):
				_plugin_singleton.hide_banner_ad(a_ad_id)
			else:
				Admob.log_error("Cannot hide banner. Ad with ID '%s' not found." % a_ad_id)


func remove_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot remove banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.remove_banner_ad(_active_banner_ads.erase_last())	# remove last ad to load
		else:
			if _active_banner_ads.has_key(a_ad_id):
				_active_banner_ads.erase(a_ad_id)
				_plugin_singleton.remove_banner_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove banner ad. Ad with ID '%s' not found." % a_ad_id)


func move_banner_ad(a_ad_id: String, a_x: float, a_y: float) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.move_banner_ad(a_ad_id, a_x, a_y)


func get_banner_dimension(a_ad_id: String = "") -> Vector2:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot get banner ad dimensions. No banner ads loaded.")
			else:
				var last_loaded_banner_ad_id = _active_banner_ads.last_key()
				return Vector2(_plugin_singleton.get_banner_width(last_loaded_banner_ad_id),
							_plugin_singleton.get_banner_height(last_loaded_banner_ad_id))
		else:
			return Vector2(_plugin_singleton.get_banner_width(a_ad_id),
						_plugin_singleton.get_banner_height(a_ad_id))

	return Vector2.ZERO


func get_banner_dimension_in_pixels(a_ad_id: String = "") -> Vector2:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot get banner ad dimensions. No banner ads loaded.")
			else:
				var last_loaded_banner_ad_id = _active_banner_ads.last_key()
				return Vector2(_plugin_singleton.get_banner_width_in_pixels(last_loaded_banner_ad_id),
							_plugin_singleton.get_banner_height_in_pixels(last_loaded_banner_ad_id))
		else:
			return Vector2(_plugin_singleton.get_banner_width_in_pixels(a_ad_id),
						_plugin_singleton.get_banner_height_in_pixels(a_ad_id))

	return Vector2.ZERO


func get_current_adaptive_banner_size(a_width: int) -> AdSize:
	var __ad_size: AdSize

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return AdSize.new(_plugin_singleton.get_current_adaptive_banner_size(a_width))

	return __ad_size


func get_portrait_adaptive_banner_size(a_width: int) -> AdSize:
	var __ad_size: AdSize

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return AdSize.new(_plugin_singleton.get_portrait_adaptive_banner_size(a_width))

	return __ad_size


func get_landscape_adaptive_banner_size(a_width: int) -> AdSize:
	var __ad_size: AdSize

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return AdSize.new(_plugin_singleton.get_landscape_adaptive_banner_size(a_width))

	return __ad_size


func create_interstitial_ad_request() -> LoadAdRequest:
	return create_basic_ad_request().set_ad_unit_id(_interstitial_id)


func load_interstitial_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = create_interstitial_ad_request()
		_plugin_singleton.load_interstitial_ad(a_request.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_interstitial_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_interstitial_ads.is_empty() == false
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_interstitial_ads.is_empty():
				Admob.log_error("Cannot show interstitial ad. No interstitial ads loaded.")
			else:
				_plugin_singleton.show_interstitial_ad(_active_interstitial_ads.last_key())	# show last ad to load
		else:
			_plugin_singleton.show_interstitial_ad(a_ad_id)


func remove_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_interstitial_ads.is_empty():
				Admob.log_error("Cannot remove interstitial ad. No interstitial ads loaded.")
			else:
				_plugin_singleton.remove_interstitial_ad(_active_interstitial_ads.erase_last())	# remove last ad to load
		else:
			if _active_interstitial_ads.has_key(a_ad_id):
				_active_interstitial_ads.erase(a_ad_id)
				_plugin_singleton.remove_interstitial_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func create_rewarded_ad_request() -> LoadAdRequest:
	return create_basic_ad_request().set_ad_unit_id(_rewarded_id)


func load_rewarded_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = create_rewarded_ad_request()
		_plugin_singleton.load_rewarded_ad(a_request.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_rewarded_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_rewarded_ads.is_empty() == false
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_rewarded_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_ads.is_empty():
				Admob.log_error("Cannot show rewarded ad. No rewarded ads loaded.")
			else:
				_plugin_singleton.show_rewarded_ad(_active_rewarded_ads.last_key())	# show last ad to load
		else:
			_plugin_singleton.show_rewarded_ad(a_ad_id)


func remove_rewarded_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_ads.is_empty():
				Admob.log_error("Cannot remove rewarded ad. No rewarded ads loaded.")
			else:
				_plugin_singleton.remove_rewarded_ad(_active_rewarded_ads.erase_last())	# remove last ad to load
		else:
			if _active_rewarded_ads.has_key(a_ad_id):
				_active_rewarded_ads.erase(a_ad_id)
				_plugin_singleton.remove_rewarded_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove rewarded ad. Ad with ID '%s' not found." % a_ad_id)


func create_rewarded_interstitial_ad_request() -> LoadAdRequest:
	return create_basic_ad_request().set_ad_unit_id(_rewarded_interstitial_id)


func load_rewarded_interstitial_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = create_rewarded_interstitial_ad_request()
		_plugin_singleton.load_rewarded_interstitial_ad(a_request.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_rewarded_interstitial_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_rewarded_interstitial_ads.is_empty() == false
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_rewarded_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_interstitial_ads.is_empty():
				Admob.log_error("Cannot show rewarded interstitial ad. No rewarded interstitial ads loaded.")
			else:
				_plugin_singleton.show_rewarded_interstitial_ad(_active_rewarded_interstitial_ads.last_key())		# show last ad to load
		else:
			_plugin_singleton.show_rewarded_interstitial_ad(a_ad_id)


func remove_rewarded_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_interstitial_ads.is_empty():
				Admob.log_error("Cannot remove rewarded interstitial ad. No rewarded interstitial ads loaded.")
			else:
				_plugin_singleton.remove_rewarded_interstitial_ad(_active_rewarded_interstitial_ads.erase_last())	# remove last ad to load
		else:
			if _active_rewarded_interstitial_ads.has_key(a_ad_id):
				_active_rewarded_interstitial_ads.erase(a_ad_id)
				_plugin_singleton.remove_rewarded_interstitial_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove rewarded interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func load_app_open_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_request == null:
			a_request = LoadAdRequest.new().set_ad_unit_id(_app_open_id).set_request_agent(request_agent)
			if is_mediation_enabled():
				a_request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))
		_plugin_singleton.load_app_open_ad(a_request.get_raw_data(), auto_show_on_resume)


func show_app_open_ad() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.show_app_open_ad()


func is_app_open_ad_available() -> bool:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
		return false
	else:
		return _plugin_singleton.is_app_open_ad_available()


func create_native_ad_request() -> LoadAdRequest:
	return (create_basic_ad_request().set_ad_unit_id(_native_id))


func load_native_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = create_native_ad_request()
		_plugin_singleton.load_native_ad(a_request.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_native_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_native_ads.is_empty() == false
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	
	return false


func show_native_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_native_ads.is_empty():
				Admob.log_error("Cannot show native ad. No native ads loaded.")
			else:
				_plugin_singleton.show_native_ad(_active_native_ads.last_key())
		else:
			if _active_native_ads.has_key(a_ad_id):
				_plugin_singleton.show_native_ad(a_ad_id)
			else:
				Admob.log_error("Cannot show native ad. Ad with ID '%s' not found." % a_ad_id)


func hide_native_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_native_ads.is_empty():
				Admob.log_error("Cannot hide native ad. No native ads loaded.")
			else:
				_plugin_singleton.hide_native_ad(_active_native_ads.last_key())
		else:
			if _active_native_ads.has_key(a_ad_id):
				_plugin_singleton.hide_native_ad(a_ad_id)
			else:
				Admob.log_error("Cannot hide native ad. Ad with ID '%s' not found." % a_ad_id)


func remove_native_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_native_ads.is_empty():
				Admob.log_error("Cannot remove native ad. No native ads loaded.")
			else:
				var _ad_id = _active_native_ads.erase_last()
				detach_native_ad(_ad_id)
				_plugin_singleton.remove_native_ad(_ad_id)
		else:
			if _active_native_ads.has_key(a_ad_id):
				_active_native_ads.erase(a_ad_id)
				detach_native_ad(a_ad_id)
				_plugin_singleton.remove_native_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove native ad. Ad with ID '%s' not found." % a_ad_id)


## Attaches a native ad to a Control node. The native ad will follow the Control's position, size and visibility.
func attach_native_ad_to_control(ad_id: String, control: Control) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if ad_id.is_empty() or control == null:
			Admob.log_error("Cannot attach native ad to control. Either Ad with ID '%s' not found, or control is null" % ad_id)
		else:
			if _native_control_bindings.has(ad_id):
				Admob.log_info("Native ad %s re-attached to new control" % ad_id)
			_native_control_bindings[ad_id] = control
			_sync_native_ad_with_control(ad_id, control) # Initial sync


func detach_native_ad(ad_id: String) -> void:
	if _native_control_bindings.has(ad_id):
		_native_control_bindings.erase(ad_id)


func _sync_native_ad_with_control(ad_id: String, control: Control) -> void:
	if not is_instance_valid(control):
		detach_native_ad(ad_id)
		return
	
	var viewport := control.get_viewport()
	var vp_rect := viewport.get_visible_rect()
	var window_size := DisplayServer.window_get_size()
	
	var scale_x := window_size.x / vp_rect.size.x
	var scale_y := window_size.y / vp_rect.size.y
	
	var canvas_pos := control.get_global_transform_with_canvas().origin
	var canvas_size := control.get_rect().size
	
	var win_x := (canvas_pos.x - vp_rect.position.x) * scale_x
	var win_y := (canvas_pos.y - vp_rect.position.y) * scale_y
	var win_w := canvas_size.x * scale_x
	var win_h := canvas_size.y * scale_y
	_plugin_singleton.update_native_ad_layout(ad_id, int(win_x), int(win_y), int(win_w), int(win_h), control.is_visible_in_tree())


func _process(_delta):
	for ad_id in _native_control_bindings.keys():
		var control = _native_control_bindings[ad_id]
		_sync_native_ad_with_control(ad_id, control)


func load_consent_form() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.load_consent_form()


func show_consent_form() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.show_consent_form()


func get_consent_status() -> UserConsent:
	var __result: String

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		__result = _plugin_singleton.get_consent_status()

	return UserConsent.new(__result) if __result else null


func is_consent_form_available() -> bool:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return _plugin_singleton.is_consent_form_available()
	return false


func update_consent_info(a_parameters: ConsentRequestParameters = null) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_parameters == null:
			a_parameters = ConsentRequestParameters.new()

			if under_age_of_consent != AdmobConfig.TagForUnderAgeOfConsent.UNSPECIFIED:
				a_parameters.set_tag_for_under_age_of_consent(under_age_of_consent)

			if not is_real:
				if debug_geography != ConsentRequestParameters.DebugGeography.NOT_SET:
					a_parameters.set_debug_geography(debug_geography)

				for __device_id in test_device_hashed_ids:
					a_parameters.add_test_device_hashed_id(__device_id)

		a_parameters.set_is_real(is_real)

		_plugin_singleton.update_consent_info(a_parameters.get_raw_data())


func reset_consent_info() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.reset_consent_info()


func set_mediation_privacy_settings(privacySettings: NetworkPrivacySettings) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.set_mediation_privacy_settings(privacySettings
				.set_enabled_networks(MediationNetwork.get_all_enabled_tags(enabled_networks))
				.get_raw_data())


func request_tracking_authorization() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _plugin_singleton.has_method("request_tracking_authorization"):
			_plugin_singleton.request_tracking_authorization()
		else:
			Admob.log_error("request_tracking_authorization() method is not supported")


func open_app_settings() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _plugin_singleton.has_method("open_app_settings"):
			_plugin_singleton.open_app_settings()
		else:
			Admob.log_error("open_app_settings() method is not supported")


func _on_initialization_completed(status_data: Dictionary) -> void:
	if auto_configure_on_initialize:
		set_request_configuration()

	is_initialization_completed = true
	initialization_completed.emit(InitializationStatus.new(status_data))


func _on_banner_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	var __response_info: ResponseInfo = ResponseInfo.new(a_response_info)
	_active_banner_ads.cache(__ad_info.get_ad_id(), __response_info)
	banner_ad_loaded.emit(__ad_info, __response_info)


func _on_banner_ad_failed_to_load(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	banner_ad_failed_to_load.emit(AdInfo.new(a_ad_data), LoadAdError.new(error_data))


func _on_banner_ad_refreshed(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	banner_ad_refreshed.emit(AdInfo.new(a_ad_data), ResponseInfo.new(a_response_info))


func _on_banner_ad_impression(a_ad_data: Dictionary) -> void:
	banner_ad_impression.emit(AdInfo.new(a_ad_data))


func _on_banner_ad_size_measured(a_ad_data: Dictionary) -> void:
	banner_ad_size_measured.emit(AdInfo.new(a_ad_data))


func _on_banner_ad_clicked(a_ad_data: Dictionary) -> void:
	banner_ad_clicked.emit(AdInfo.new(a_ad_data))


func _on_banner_ad_opened(a_ad_data: Dictionary) -> void:
	banner_ad_opened.emit(AdInfo.new(a_ad_data))


func _on_banner_ad_closed(a_ad_data: Dictionary) -> void:
	banner_ad_closed.emit(AdInfo.new(a_ad_data))


func _on_interstitial_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	var __response_info: ResponseInfo = ResponseInfo.new(a_response_info)
	_active_interstitial_ads.cache(__ad_info.get_ad_id(), __response_info)
	interstitial_ad_loaded.emit(__ad_info, __response_info)


func _on_interstitial_ad_failed_to_load(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_load.emit(AdInfo.new(a_ad_data), LoadAdError.new(error_data))


func _on_interstitial_ad_refreshed(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	interstitial_ad_refreshed.emit(AdInfo.new(a_ad_data), ResponseInfo.new(a_response_info))


func _on_interstitial_ad_impression(a_ad_data: Dictionary) -> void:
	interstitial_ad_impression.emit(AdInfo.new(a_ad_data))


func _on_interstitial_ad_clicked(a_ad_data: Dictionary) -> void:
	interstitial_ad_clicked.emit(AdInfo.new(a_ad_data))


func _on_interstitial_ad_showed_full_screen_content(a_ad_data: Dictionary) -> void:
	interstitial_ad_showed_full_screen_content.emit(AdInfo.new(a_ad_data))


func _on_interstitial_ad_failed_to_show_full_screen_content(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_show_full_screen_content.emit(AdInfo.new(a_ad_data), AdError.new(error_data))


func _on_interstitial_ad_dismissed_full_screen_content(a_ad_data: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	if remove_interstitial_ads_after_displayed:
		remove_interstitial_ad(__ad_info.get_ad_id())
	interstitial_ad_dismissed_full_screen_content.emit(__ad_info)


func _on_rewarded_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	var __response_info: ResponseInfo = ResponseInfo.new(a_response_info)
	_active_rewarded_ads.cache(__ad_info.get_ad_id(), __response_info)
	rewarded_ad_loaded.emit(__ad_info, __response_info)


func _on_rewarded_ad_failed_to_load(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_load.emit(AdInfo.new(a_ad_data), LoadAdError.new(error_data))


func _on_rewarded_ad_impression(a_ad_data: Dictionary) -> void:
	rewarded_ad_impression.emit(AdInfo.new(a_ad_data))


func _on_rewarded_ad_clicked(a_ad_data: Dictionary) -> void:
	rewarded_ad_clicked.emit(AdInfo.new(a_ad_data))


func _on_rewarded_ad_showed_full_screen_content(a_ad_data: Dictionary) -> void:
	rewarded_ad_showed_full_screen_content.emit(AdInfo.new(a_ad_data))


func _on_rewarded_ad_failed_to_show_full_screen_content(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_show_full_screen_content.emit(AdInfo.new(a_ad_data), AdError.new(error_data))


func _on_rewarded_ad_dismissed_full_screen_content(a_ad_data: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	if remove_rewarded_ads_after_displayed:
		remove_rewarded_ad(__ad_info.get_ad_id())
	rewarded_ad_dismissed_full_screen_content.emit(__ad_info)


func _on_rewarded_ad_user_earned_reward(a_ad_data: Dictionary, reward_data: Dictionary) -> void:
	rewarded_ad_user_earned_reward.emit(AdInfo.new(a_ad_data), RewardItem.new(reward_data))


func _on_rewarded_interstitial_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	var __response_info: ResponseInfo = ResponseInfo.new(a_response_info)
	_active_rewarded_interstitial_ads.cache(__ad_info.get_ad_id(), __response_info)
	rewarded_interstitial_ad_loaded.emit(__ad_info, __response_info)


func _on_rewarded_interstitial_ad_failed_to_load(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_load.emit(AdInfo.new(a_ad_data), LoadAdError.new(error_data))


func _on_rewarded_interstitial_ad_impression(a_ad_data: Dictionary) -> void:
	rewarded_interstitial_ad_impression.emit(AdInfo.new(a_ad_data))


func _on_rewarded_interstitial_ad_clicked(a_ad_data: Dictionary) -> void:
	rewarded_interstitial_ad_clicked.emit(AdInfo.new(a_ad_data))


func _on_rewarded_interstitial_ad_showed_full_screen_content(a_ad_data: Dictionary) -> void:
	rewarded_interstitial_ad_showed_full_screen_content.emit(AdInfo.new(a_ad_data))


func _on_rewarded_interstitial_ad_failed_to_show_full_screen_content(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_show_full_screen_content.emit(AdInfo.new(a_ad_data), AdError.new(error_data))


func _on_rewarded_interstitial_ad_dismissed_full_screen_content(a_ad_data: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	if remove_rewarded_interstitial_ads_after_displayed:
		remove_rewarded_interstitial_ad(__ad_info.get_ad_id())
	rewarded_interstitial_ad_dismissed_full_screen_content.emit(__ad_info)


func _on_rewarded_interstitial_ad_user_earned_reward(a_ad_data: Dictionary, reward_data: Dictionary) -> void:
	rewarded_interstitial_ad_user_earned_reward.emit(AdInfo.new(a_ad_data), RewardItem.new(reward_data))


func _on_app_open_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	app_open_ad_loaded.emit(AdInfo.new(a_ad_data), ResponseInfo.new(a_response_info))


func _on_app_open_ad_failed_to_load(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	app_open_ad_failed_to_load.emit(AdInfo.new(a_ad_data), LoadAdError.new(error_data))


func _on_app_open_ad_impression(a_ad_data: Dictionary) -> void:
	app_open_ad_impression.emit(AdInfo.new(a_ad_data))


func _on_app_open_ad_clicked(a_ad_data: Dictionary) -> void:
	app_open_ad_clicked.emit(AdInfo.new(a_ad_data))


func _on_app_open_ad_showed_full_screen_content(a_ad_data: Dictionary) -> void:
	app_open_ad_showed_full_screen_content.emit(AdInfo.new(a_ad_data))


func _on_app_open_ad_failed_to_show_full_screen_content(a_ad_data: Dictionary, error_data: Dictionary) -> void:
	app_open_ad_failed_to_show_full_screen_content.emit(AdInfo.new(a_ad_data), AdError.new(error_data))


func _on_app_open_ad_dismissed_full_screen_content(a_ad_data: Dictionary) -> void:
	app_open_ad_dismissed_full_screen_content.emit(AdInfo.new(a_ad_data))

func _on_native_ad_loaded(a_ad_data: Dictionary, a_response_info: Dictionary) -> void:
	var __ad_info: AdInfo = AdInfo.new(a_ad_data)
	var __response_info: ResponseInfo = ResponseInfo.new(a_response_info)
	_active_native_ads.cache(__ad_info.get_ad_id(), __response_info)
	native_ad_loaded.emit(__ad_info, __response_info)


func _on_native_ad_failed_to_load(ad_data: Dictionary, error: Dictionary) -> void:
	emit_signal("native_ad_failed_to_load", ad_data, error)


func _on_native_ad_size_measured(ad_data: Dictionary) -> void:
	emit_signal("native_ad_size_measured", ad_data)


func _on_native_ad_impression(ad_data: Dictionary) -> void:
	emit_signal("native_ad_impression", ad_data)


func _on_native_ad_clicked(ad_data: Dictionary) -> void:
	emit_signal("native_ad_clicked", ad_data)


func _native_ad_swipe_gesture_clicked(ad_data: Dictionary) -> void:
	emit_signal("native_ad_swipe_gesture_clicked", ad_data)


func _on_native_ad_opened(ad_data: Dictionary) -> void:
	emit_signal("native_ad_opened", ad_data)


func _on_native_ad_closed(ad_data: Dictionary) -> void:
	emit_signal("native_ad_closed", ad_data)


func _on_consent_form_loaded() -> void:
	consent_form_loaded.emit()


func _on_consent_form_dismissed(error_data: Dictionary) -> void:
	consent_form_dismissed.emit(FormError.new(error_data))


func _on_consent_form_failed_to_load(error_data: Dictionary) -> void:
	consent_form_failed_to_load.emit(FormError.new(error_data))


func _on_consent_info_updated() -> void:
	consent_info_updated.emit()


func _on_consent_info_update_failed(error_data: Dictionary) -> void:
	consent_info_update_failed.emit(FormError.new(error_data))


func _on_tracking_authorization_granted() -> void:
	tracking_authorization_granted.emit()


func _on_tracking_authorization_denied() -> void:
	tracking_authorization_denied.emit()


static func log_error(a_description: String) -> void:
	push_error("%s: %s" % [PLUGIN_SINGLETON_NAME, a_description])


static func log_warn(a_description: String) -> void:
	push_warning("%s: %s" % [PLUGIN_SINGLETON_NAME, a_description])


static func log_info(a_description: String) -> void:
	print_rich("[color=lime]%s: INFO: %s[/color]" % [PLUGIN_SINGLETON_NAME, a_description])
