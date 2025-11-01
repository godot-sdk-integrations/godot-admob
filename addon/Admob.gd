#
# © 2024-present https://github.com/cengiz-pz
#

@tool
class_name Admob extends Node

signal initialization_completed(status_data: InitializationStatus)
signal banner_ad_loaded(ad_id: String)
signal banner_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal banner_ad_refreshed(ad_id: String)
signal banner_ad_clicked(ad_id: String)
signal banner_ad_impression(ad_id: String)
signal banner_ad_opened(ad_id: String)
signal banner_ad_closed(ad_id: String)
signal interstitial_ad_loaded(ad_id: String)
signal interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal interstitial_ad_refreshed(ad_id: String)
signal interstitial_ad_impression(ad_id: String)
signal interstitial_ad_clicked(ad_id: String)
signal interstitial_ad_showed_full_screen_content(ad_id: String)
signal interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal interstitial_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_ad_loaded(ad_id: String)
signal rewarded_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal rewarded_ad_impression(ad_id: String)
signal rewarded_ad_clicked(ad_id: String)
signal rewarded_ad_showed_full_screen_content(ad_id: String)
signal rewarded_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal rewarded_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)
signal rewarded_interstitial_ad_loaded(ad_id: String)
signal rewarded_interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal rewarded_interstitial_ad_impression(ad_id: String)
signal rewarded_interstitial_ad_clicked(ad_id: String)
signal rewarded_interstitial_ad_showed_full_screen_content(ad_id: String)
signal rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal rewarded_interstitial_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_interstitial_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)
signal app_open_ad_loaded(ad_id: String)
signal app_open_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal app_open_ad_impression(ad_id: String)
signal app_open_ad_clicked(ad_id: String)
signal app_open_ad_showed_full_screen_content(ad_id: String)
signal app_open_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal app_open_ad_dismissed_full_screen_content(ad_id: String)
signal consent_form_loaded
signal consent_form_dismissed(error_data: FormError)
signal consent_form_failed_to_load(error_data: FormError)
signal consent_info_updated
signal consent_info_update_failed(error_data: FormError)
signal tracking_authorization_granted
signal tracking_authorization_denied

const PLUGIN_SINGLETON_NAME: String = "@pluginName@"

const ANDROID_BANNER_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6300978111"
const ANDROID_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1033173712"
const ANDROID_REWARDED_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5224354917"
const ANDROID_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5354046379"
const ANDROID_APP_OPEN_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/9257395921"

const IOS_BANNER_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/2934735716"
const IOS_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/4411468910"
const IOS_REWARDED_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/1712485313"
const IOS_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/6978759866"
const IOS_APP_OPEN_DEMO_AD_UNIT_ID: String = "ca-app-pub-3940256099942544/5575463023"

@export_category("General")
@export var is_real: bool: set = set_is_real
@export var max_ad_content_rating: AdmobConfig.ContentRating = AdmobConfig.ContentRating.G: set = set_max_ad_content_rating
@export var child_directed: AdmobConfig.TagForChildDirectedTreatment = AdmobConfig.TagForChildDirectedTreatment.UNSPECIFIED: set = set_child_directed
@export var under_age_of_consent: AdmobConfig.TagForUnderAgeOfConsent = AdmobConfig.TagForUnderAgeOfConsent.UNSPECIFIED: set = set_under_age_of_consent
@export var first_party_id_enabled: bool = true: set = set_first_party_id_enabled
@export var personalization_state: AdmobConfig.PersonalizationState = AdmobConfig.PersonalizationState.DEFAULT: set = set_personalization_state
@export var request_agent: String = PLUGIN_SINGLETON_NAME: set = set_request_agent

@export_category("Banner")
@export var banner_position: LoadAdRequest.AdPosition = LoadAdRequest.AdPosition.TOP: set = set_banner_position
@export var banner_size: LoadAdRequest.AdSize = LoadAdRequest.AdSize.BANNER: set = set_banner_size

@export_category("App Open")
@export var auto_show_on_resume: bool = false: set = set_auto_show_on_resume

@export_category("Android-specific")
@export_group("Android Application IDs","android_")
@export var android_debug_application_id: String = ""
@export var android_real_application_id: String = ""

@export_group("Android Debug Ad Unit IDs", "android_debug_")
@export var android_debug_banner_id: String = ANDROID_BANNER_DEMO_AD_UNIT_ID
@export var android_debug_interstitial_id: String = ANDROID_INTERSTITIAL_DEMO_AD_UNIT_ID
@export var android_debug_rewarded_id: String = ANDROID_REWARDED_DEMO_AD_UNIT_ID
@export var android_debug_rewarded_interstitial_id: String = ANDROID_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID
@export var android_debug_app_open_id: String = ANDROID_APP_OPEN_DEMO_AD_UNIT_ID

@export_group("Android Real Ad Unit IDs", "android_real_")
@export var android_real_banner_id: String = ""
@export var android_real_interstitial_id: String = ""
@export var android_real_rewarded_id: String = ""
@export var android_real_rewarded_interstitial_id: String = ""
@export var android_real_app_open_id: String = ""

@export_category("iOS-specific")
@export_group("iOS Application IDs","ios_")
@export var ios_debug_application_id: String = ""
@export var ios_real_application_id: String = ""

@export_group("iOS Debug Ad Unit IDs", "ios_debug_")
@export var ios_debug_banner_id: String = IOS_BANNER_DEMO_AD_UNIT_ID
@export var ios_debug_interstitial_id: String = IOS_INTERSTITIAL_DEMO_AD_UNIT_ID
@export var ios_debug_rewarded_id: String = IOS_REWARDED_DEMO_AD_UNIT_ID
@export var ios_debug_rewarded_interstitial_id: String = IOS_REWARDED_INTERSTITIAL_DEMO_AD_UNIT_ID
@export var ios_debug_app_open_id: String = IOS_APP_OPEN_DEMO_AD_UNIT_ID

@export_group("iOS Real Ad Unit IDs", "ios_real_")
@export var ios_real_banner_id: String = ""
@export var ios_real_interstitial_id: String = ""
@export var ios_real_rewarded_id: String = ""
@export var ios_real_rewarded_interstitial_id: String = ""
@export var ios_real_app_open_id: String = ""

@export_category("Mediation")
@export_group("Networks")
@export_flags(" ") var enabled_networks = 0	# Networks populated in _validate_property()
@export_group("Network Extras")
@export var network_extras: Array[NetworkExtras] = []

@export_category("App Tracking Transparency")
@export var att_enabled: bool = false:
	get:
		return att_enabled
	set(value):
		att_enabled = value
@export_multiline var att_text: String = "": set = set_att_text

@export_category("Cache")
@export_group("Limits")
@export_range(1,100) var max_banner_ad_cache: int = 3: set = set_max_banner_ad_cache
@export_range(1,100) var max_interstitial_ad_cache: int = 3: set = set_max_interstitial_ad_cache
@export_range(1,100) var max_rewarded_ad_cache: int = 3: set = set_max_rewarded_ad_cache
@export_range(1,100) var max_rewarded_interstitial_ad_cache: int = 3: set = set_max_rewarded_interstitial_ad_cache

@export_group("Cleanup After Ad Displayed")
@export var remove_banner_ads_after_displayed: bool = true
@export var remove_interstitial_ads_after_displayed: bool = true
@export var remove_rewarded_ads_after_displayed: bool = true
@export var remove_rewarded_interstitial_ads_after_displayed: bool = true

@export_group("Cleanup After Scene Exit")
@export var remove_banner_ads_after_scene: bool = true
@export var remove_interstitial_ads_after_scene: bool = true
@export var remove_rewarded_ads_after_scene: bool = true
@export var remove_rewarded_interstitial_ads_after_scene: bool = true

@export_category("Debug")
@export_group("Settings")
@export var debug_geography: ConsentRequestParameters.DebugGeography = ConsentRequestParameters.DebugGeography.NOT_SET : set = set_debug_geography
@export var add_test_device_id: bool = false : set = set_add_test_device_id

var _banner_id: String
var _interstitial_id: String
var _rewarded_id: String
var _rewarded_interstitial_id: String
var _app_open_id: String

var _plugin_singleton: Object

var _active_banner_ads: Array
var _active_interstitial_ads: Array
var _active_rewarded_ads: Array
var _active_rewarded_interstitial_ads: Array


func _init() -> void:
	_active_banner_ads = []
	_active_interstitial_ads = []
	_active_rewarded_ads = []
	_active_rewarded_interstitial_ads = []


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
		else:
			_banner_id = ios_debug_banner_id
			_interstitial_id = ios_debug_interstitial_id
			_rewarded_id = ios_debug_rewarded_id
			_rewarded_interstitial_id = ios_debug_rewarded_interstitial_id
			_app_open_id = ios_debug_app_open_id
	else:
		if is_real:
			_banner_id = android_real_banner_id
			_interstitial_id = android_real_interstitial_id
			_rewarded_id = android_real_rewarded_id
			_rewarded_interstitial_id = android_real_rewarded_interstitial_id
			_app_open_id = android_real_app_open_id
		else:
			_banner_id = android_debug_banner_id
			_interstitial_id = android_debug_interstitial_id
			_rewarded_id = android_debug_rewarded_id
			_rewarded_interstitial_id = android_debug_rewarded_interstitial_id
			_app_open_id = android_debug_app_open_id

	_update_plugin()


func _exit_tree() -> void:
	if remove_banner_ads_after_scene:
		for __ad_id in _active_banner_ads:
			remove_banner_ad(__ad_id)

	if remove_interstitial_ads_after_scene:
		for __ad_id in _active_interstitial_ads:
			remove_interstitial_ad(__ad_id)

	if remove_rewarded_ads_after_scene:
		for __ad_id in _active_rewarded_ads:
			remove_rewarded_ad(__ad_id)

	if remove_rewarded_interstitial_ads_after_scene:
		for __ad_id in _active_rewarded_interstitial_ads:
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
	_plugin_singleton.connect("banner_ad_clicked", _on_banner_ad_clicked)
	_plugin_singleton.connect("banner_ad_impression", _on_banner_ad_impression)
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


func set_banner_size(a_value: LoadAdRequest.AdSize) -> void:
	banner_size = a_value


func set_auto_show_on_resume(a_value: bool) -> void:
	auto_show_on_resume = a_value


func set_max_banner_ad_cache(a_value: int) -> void:
	max_banner_ad_cache = a_value


func set_max_interstitial_ad_cache(a_value: int) -> void:
	max_interstitial_ad_cache = a_value


func set_max_rewarded_ad_cache(a_value: int) -> void:
	max_rewarded_ad_cache = a_value


func set_max_rewarded_interstitial_ad_cache(a_value: int) -> void:
	max_rewarded_interstitial_ad_cache = a_value


func set_debug_geography(a_value: ConsentRequestParameters.DebugGeography) -> void:
	debug_geography = a_value


func set_add_test_device_id(a_value: bool) -> void:
	add_test_device_id = a_value


func is_mediation_enabled() -> bool:
	return enabled_networks > 0


func configure_ads() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.set_request_configuration(AdmobConfig.new()
					.set_is_real(is_real)
					.set_max_ad_content_rating(max_ad_content_rating)
					.set_child_directed_treatment(child_directed)
					.set_under_age_of_consent(under_age_of_consent)
					.set_first_party_id_enabled(first_party_id_enabled)
					.set_personalization_state(personalization_state)
					.get_raw_data())
	else:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func load_banner_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = (LoadAdRequest.new()
					.set_ad_unit_id(_banner_id)
					.set_ad_position(banner_position)
					.set_ad_size(banner_size)
					.set_request_agent(request_agent))
			if is_mediation_enabled():
				a_request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))
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
				_plugin_singleton.show_banner_ad(_active_banner_ads[0])	# show last ad to load
		else:
			if _active_banner_ads.has(a_ad_id):
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
				_plugin_singleton.hide_banner_ad(_active_banner_ads[0])	# hide last ad to load
		else:
			if _active_banner_ads.has(a_ad_id):
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
				_plugin_singleton.remove_banner_ad(_active_banner_ads[0])	# remove last ad to load
				_active_banner_ads.remove_at(0)
		else:
			if _active_banner_ads.has(a_ad_id):
				_active_banner_ads.erase(a_ad_id)
				_plugin_singleton.remove_banner_ad(a_ad_id)
			else:
				Admob.log_error("Cannot remove banner ad. Ad with ID '%s' not found." % a_ad_id)


func get_banner_dimension(a_ad_id: String = "") -> Vector2:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				Admob.log_error("Cannot get banner ad dimensions. No banner ads loaded.")
			else:
				var last_loaded_banner_ad_id = _active_banner_ads[0]
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
				var last_loaded_banner_ad_id = _active_banner_ads[0]
				return Vector2(_plugin_singleton.get_banner_width_in_pixels(last_loaded_banner_ad_id),
							_plugin_singleton.get_banner_height_in_pixels(last_loaded_banner_ad_id))
		else:
			return Vector2(_plugin_singleton.get_banner_height_in_pixels(a_ad_id),
						_plugin_singleton.get_banner_height_in_pixels(a_ad_id))

	return Vector2.ZERO


func load_interstitial_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = LoadAdRequest.new().set_ad_unit_id(_interstitial_id).set_request_agent(request_agent)
			if is_mediation_enabled():
				a_request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))
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
				_plugin_singleton.show_interstitial_ad(_active_interstitial_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_interstitial_ad(a_ad_id)


func remove_interstitial_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_interstitial_ads.has(a_ad_id):
			_active_interstitial_ads.erase(a_ad_id)
			_plugin_singleton.remove_interstitial_ad(a_ad_id)
		else:
			Admob.log_error("Cannot remove interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func load_rewarded_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = LoadAdRequest.new().set_ad_unit_id(_rewarded_id).set_request_agent(request_agent)
			if is_mediation_enabled():
				a_request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))
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
				_plugin_singleton.show_rewarded_ad(_active_rewarded_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_rewarded_ad(a_ad_id)


func remove_rewarded_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_rewarded_ads.has(a_ad_id):
			_active_rewarded_ads.erase(a_ad_id)
			_plugin_singleton.remove_rewarded_ad(a_ad_id)
		else:
			Admob.log_error("Cannot remove rewarded ad. Ad with ID '%s' not found." % a_ad_id)


func load_rewarded_interstitial_ad(a_request: LoadAdRequest = null) -> void:
	if _plugin_singleton != null:
		if a_request == null:
			a_request = LoadAdRequest.new().set_ad_unit_id(_rewarded_interstitial_id).set_request_agent(request_agent)
			if is_mediation_enabled():
				a_request.set_network_extras(NetworkExtras.build_raw_data_array(network_extras))
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
				_plugin_singleton.show_rewarded_interstitial_ad(_active_rewarded_interstitial_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_rewarded_interstitial_ad(a_ad_id)


func remove_rewarded_interstitial_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_rewarded_interstitial_ads.has(a_ad_id):
			_active_rewarded_interstitial_ads.erase(a_ad_id)
			_plugin_singleton.remove_rewarded_interstitial_ad(a_ad_id)
		else:
			Admob.log_error("Cannot remove rewarded interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func load_app_open_ad(a_ad_id: String = _app_open_id) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.load_app_open_ad(a_ad_id, auto_show_on_resume)


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


func get_consent_status() -> String:
	var __result: String

	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		__result = _plugin_singleton.get_consent_status()

	return __result


func is_consent_form_available() -> bool:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return _plugin_singleton.is_consent_form_available()
	return false


func update_consent_info(consentRequestParameters: ConsentRequestParameters) -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		consentRequestParameters.set_is_real(is_real)

		if not is_real:
			if debug_geography != ConsentRequestParameters.DebugGeography.NOT_SET:
				consentRequestParameters.set_debug_geography(debug_geography)

			if add_test_device_id:
				consentRequestParameters.add_test_device_hashed_id(OS.get_unique_id())

		_plugin_singleton.update_consent_info(consentRequestParameters.get_raw_data())


func reset_consent_info() -> void:
	if _plugin_singleton == null:
		Admob.log_error("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.reset_consent_info()


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
	configure_ads()
	initialization_completed.emit(InitializationStatus.new(status_data))


func _on_banner_ad_loaded(a_ad_id: String) -> void:
	_active_banner_ads.push_front(a_ad_id)
	while _active_banner_ads.size() > max_banner_ad_cache:
		Admob.log_warn("%s: banner_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_banner_ads.size(), max_banner_ad_cache])
		var removed_ad_id: String = _active_banner_ads.pop_back()
		_plugin_singleton.remove_banner_ad(removed_ad_id)
	banner_ad_loaded.emit(a_ad_id)


func _on_banner_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	banner_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_banner_ad_refreshed(a_ad_id: String) -> void:
	banner_ad_refreshed.emit(a_ad_id)


func _on_banner_ad_impression(a_ad_id: String) -> void:
	if remove_banner_ads_after_displayed:
		_active_banner_ads.erase(a_ad_id)
		remove_banner_ad(a_ad_id)
	banner_ad_impression.emit(a_ad_id)


func _on_banner_ad_clicked(a_ad_id: String) -> void:
	banner_ad_clicked.emit(a_ad_id)


func _on_banner_ad_opened(a_ad_id: String) -> void:
	banner_ad_opened.emit(a_ad_id)


func _on_banner_ad_closed(a_ad_id: String) -> void:
	banner_ad_closed.emit(a_ad_id)


func _on_interstitial_ad_loaded(a_ad_id: String) -> void:
	_active_interstitial_ads.push_front(a_ad_id)
	while _active_interstitial_ads.size() > max_interstitial_ad_cache:
		Admob.log_warn("%s: interstitial_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_interstitial_ads.size(), max_interstitial_ad_cache])
		var removed_ad_id: String = _active_interstitial_ads.pop_back()
		_plugin_singleton.remove_interstitial_ad(removed_ad_id)
	interstitial_ad_loaded.emit(a_ad_id)


func _on_interstitial_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_interstitial_ad_refreshed(a_ad_id: String) -> void:
	interstitial_ad_refreshed.emit(a_ad_id)


func _on_interstitial_ad_impression(a_ad_id: String) -> void:
	interstitial_ad_impression.emit(a_ad_id)



func _on_interstitial_ad_clicked(a_ad_id: String) -> void:
	interstitial_ad_clicked.emit(a_ad_id)


func _on_interstitial_ad_showed_full_screen_content(a_ad_id: String) -> void:
	if remove_interstitial_ads_after_displayed:
		_active_interstitial_ads.erase(a_ad_id)
		remove_interstitial_ad(a_ad_id)
	interstitial_ad_showed_full_screen_content.emit(a_ad_id)


func _on_interstitial_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_interstitial_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	interstitial_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_loaded(a_ad_id: String) -> void:
	_active_rewarded_ads.push_front(a_ad_id)
	while _active_rewarded_ads.size() > max_rewarded_ad_cache:
		Admob.log_warn("%s: rewarded_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_rewarded_ads.size(), max_rewarded_ad_cache])
		var removed_ad_id: String = _active_rewarded_ads.pop_back()
		_plugin_singleton.remove_rewarded_ad(removed_ad_id)
	rewarded_ad_loaded.emit(a_ad_id)


func _on_rewarded_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_rewarded_ad_impression(a_ad_id: String) -> void:
	rewarded_ad_impression.emit(a_ad_id)


func _on_rewarded_ad_clicked(a_ad_id: String) -> void:
	rewarded_ad_clicked.emit(a_ad_id)


func _on_rewarded_ad_showed_full_screen_content(a_ad_id: String) -> void:
	if remove_rewarded_ads_after_displayed:
		_active_rewarded_ads.erase(a_ad_id)
		remove_rewarded_ad(a_ad_id)
	rewarded_ad_showed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_rewarded_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	rewarded_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_user_earned_reward(a_ad_id: String, reward_data: Dictionary) -> void:
	rewarded_ad_user_earned_reward.emit(a_ad_id, RewardItem.new(reward_data))


func _on_rewarded_interstitial_ad_loaded(a_ad_id: String) -> void:
	_active_rewarded_interstitial_ads.push_front(a_ad_id)
	while _active_rewarded_interstitial_ads.size() > max_rewarded_interstitial_ad_cache:
		Admob.log_warn("%s: rewarded_interstitial_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_rewarded_interstitial_ads.size(), max_rewarded_interstitial_ad_cache])
		var removed_ad_id: String = _active_rewarded_interstitial_ads.pop_back()
		_plugin_singleton.remove_rewarded_interstitial_ad(removed_ad_id)
	rewarded_interstitial_ad_loaded.emit(a_ad_id)


func _on_rewarded_interstitial_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_rewarded_interstitial_ad_impression(a_ad_id: String) -> void:
	rewarded_interstitial_ad_impression.emit(a_ad_id)


func _on_rewarded_interstitial_ad_clicked(a_ad_id: String) -> void:
	rewarded_interstitial_ad_clicked.emit(a_ad_id)


func _on_rewarded_interstitial_ad_showed_full_screen_content(a_ad_id: String) -> void:
	if remove_rewarded_interstitial_ads_after_displayed:
		_active_rewarded_interstitial_ads.erase(a_ad_id)
		remove_rewarded_interstitial_ad(a_ad_id)
	rewarded_interstitial_ad_showed_full_screen_content.emit(a_ad_id)


func _on_rewarded_interstitial_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_rewarded_interstitial_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	rewarded_interstitial_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_interstitial_ad_user_earned_reward(a_ad_id: String, reward_data: Dictionary) -> void:
	rewarded_interstitial_ad_user_earned_reward.emit(a_ad_id, RewardItem.new(reward_data))


func _on_app_open_ad_loaded(a_ad_id: String) -> void:
	app_open_ad_loaded.emit(a_ad_id)


func _on_app_open_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	app_open_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_app_open_ad_impression(a_ad_id: String) -> void:
	app_open_ad_impression.emit(a_ad_id)


func _on_app_open_ad_clicked(a_ad_id: String) -> void:
	app_open_ad_clicked.emit(a_ad_id)


func _on_app_open_ad_showed_full_screen_content(a_ad_id: String) -> void:
	app_open_ad_showed_full_screen_content.emit(a_ad_id)


func _on_app_open_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	app_open_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_app_open_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	app_open_ad_dismissed_full_screen_content.emit(a_ad_id)


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
	push_error(a_description)


static func log_warn(a_description: String) -> void:
	push_warning(a_description)


static func log_info(a_description: String) -> void:
	print_rich("[color=lime]INFO: %s[/color]" % a_description)
