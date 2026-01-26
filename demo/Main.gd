#
# © 2024-present https://github.com/cengiz-pz
#

extends Node

@onready var admob: Admob = $Admob as Admob
@onready var ad_id_option_button: OptionButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/IDHBoxContainer/AdIdOptionButton
@onready var show_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/ButtonsHBoxContainer/ShowBannerButton
@onready var hide_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/ButtonsHBoxContainer/HideBannerButton
@onready var size_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/ButtonsHBoxContainer/SizeButton
@onready var size_px_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/ButtonsHBoxContainer/PixelSizeButton
@onready var remove_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/ButtonsHBoxContainer/RemoveBannerButton
@onready var load_banner_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/LoadButtonHBoxContainer/LoadBannerButton
@onready var banner_position_option_button: OptionButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/PositionHBoxContainer/OptionButton
@onready var banner_size_option_button: OptionButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/SizeHBoxContainer/OptionButton
@onready var banner_collapsible_pos_option_button: OptionButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/CollapsiblePosHBoxContainer/OptionButton
@onready var banner_anchor_at_safe_area_check_box: CheckBox = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Banner/AnchorHBoxContainer/CheckBox
@onready var load_native_ad_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/LoadNativeAdButton
@onready var native_ad_id_option_button: OptionButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/IDHBoxContainer/AdIdOptionButton
@onready var show_native_ad_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/ButtonsHBoxContainer/ShowNativeAdButton
@onready var hide_native_ad_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/ButtonsHBoxContainer/HideNativeAdButton
@onready var attach_native_ad_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/ButtonsHBoxContainer/AttachNativeAdButton
@onready var remove_native_ad_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Native/ButtonsHBoxContainer/RemoveNativeAdButton

@onready var interstitial_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/InterstitialHBoxContainer/InterstitialButton
@onready var rewarded_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/RewardedHBoxContainer/RewardedButton
@onready var rewarded_interstitial_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/RewardedInterstitialHBoxContainer/RewardedInterstitialButton
@onready var reload_interstitial_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/InterstitialHBoxContainer/ReloadInterstitialButton
@onready var reload_rewarded_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/RewardedHBoxContainer/ReloadRewardedButton
@onready var reload_rewarded_interstitial_button: Button = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Other/RewardedInterstitialHBoxContainer/ReloadRewardedInterstitialButton
@onready var consent_status_label: Label = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Consent/VBoxContainer/StatusHBoxContainer/ValueLabel
@onready var volume_hslider: HSlider = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Settings/SettingsVBC/VolumeHBC/VolumeHSlider
@onready var volume_value_label: Label = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Settings/SettingsVBC/VolumeHBC/ValueLabel
@onready var muted_checkbutton: CheckButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Settings/SettingsVBC/MuteHBC/CheckButton
@onready var startup_checkbutton: CheckButton = $CanvasLayer/MainContainer/VBoxContainer/VBoxContainer/TabContainer/Settings/SettingsVBC/StartupHBC/CheckButton
@onready var _label: RichTextLabel = $CanvasLayer/MainContainer/VBoxContainer/RichTextLabel as RichTextLabel
@onready var _android_texture_rect: TextureRect = $CanvasLayer/MainContainer/VBoxContainer/TextureHBoxContainer/AndroidTextureRect as TextureRect
@onready var _ios_texture_rect: TextureRect = $CanvasLayer/MainContainer/VBoxContainer/TextureHBoxContainer/iOSTextureRect as TextureRect

var _active_texture_rect: TextureRect

var _is_banner_loading = false
var _is_app_open_ad_displayed_at_startup: bool = false
var _is_interstitial_loaded: bool = false
var _is_rewarded_video_loaded: bool = false
var _is_rewarded_interstitial_loaded: bool = false
var _is_native_ad_loading = false

var _consent_status: String = UserConsent.status_to_string(UserConsent.Status.UNKNOWN):
	set(a_value):
		_consent_status = a_value
		consent_status_label.text = a_value
	

func _ready() -> void:
	if OS.has_feature("ios"):
		_android_texture_rect.hide()
		_active_texture_rect = _ios_texture_rect
	else:
		_ios_texture_rect.hide()
		_active_texture_rect = _android_texture_rect

	var __index: int = 0
	for __item: String in LoadAdRequest.AdPosition.keys():
		banner_position_option_button.add_item(__item)
		if __item.casecmp_to(LoadAdRequest.AdPosition.keys()[admob.banner_position]) == 0:
			banner_position_option_button.select(__index)
		__index += 1

	__index = 0
	for __item in LoadAdRequest.RequestedAdSize.keys():
		banner_size_option_button.add_item(__item)
		if __item.casecmp_to(LoadAdRequest.RequestedAdSize.keys()[admob.banner_size]) == 0:
			banner_size_option_button.select(__index)
		__index += 1

	__index = 0
	for __item: String in LoadAdRequest.CollapsiblePosition.keys():
		banner_collapsible_pos_option_button.add_item(__item)
		if __item.casecmp_to(LoadAdRequest.CollapsiblePosition.keys()[admob.banner_collapsible_position]) == 0:
			banner_collapsible_pos_option_button.select(__index)
		__index += 1

	admob.initialize()


func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
	for __network_tag in status_data.get_network_tags():
		var __adapter_status: AdapterStatus = status_data.get_adapter_status(__network_tag)
		_print_to_screen("Network '%s' (%s) status: %s [Latency: %d, Description: %s]" %
				[__network_tag,
				__adapter_status.get_adapter_class(),
				__adapter_status.get_initialization_state(),
				__adapter_status.get_latency(),
				__adapter_status.get_description()])
	_process_consent_status(admob.get_consent_status())


func _load_ads() -> void:
	if admob.is_app_open_ad_available():
		if not _is_app_open_ad_displayed_at_startup:
			admob.show_app_open_ad()
	else:
		admob.load_app_open_ad()

	admob.load_interstitial_ad()
	admob.load_rewarded_ad()
	admob.load_rewarded_interstitial_ad()


func _is_banner_loaded() -> bool:
	return ad_id_option_button.item_count > 0


func _update_banner_buttons() -> void:
	if _is_banner_loaded():
		show_banner_button.disabled = false
		hide_banner_button.disabled = false
		size_banner_button.disabled = false
		size_px_banner_button.disabled = false
		remove_banner_button.disabled = false
	else:
		show_banner_button.disabled = true
		hide_banner_button.disabled = true
		size_banner_button.disabled = true
		size_px_banner_button.disabled = true
		remove_banner_button.disabled = true


func _on_load_banner_button_pressed() -> void:
	load_banner_button.disabled = true

	admob.banner_position = LoadAdRequest.AdPosition[banner_position_option_button.get_item_text(banner_position_option_button.selected)]
	admob.banner_size = LoadAdRequest.RequestedAdSize[banner_size_option_button.get_item_text(banner_size_option_button.selected)]
	admob.banner_collapsible_position = LoadAdRequest.CollapsiblePosition[banner_collapsible_pos_option_button.get_item_text(banner_collapsible_pos_option_button.selected)]

	print(" --- Load banner button PRESSED --- pos: %s --- size: %s --- collapsible pos: %s" % [
		LoadAdRequest.AdPosition.keys()[admob.banner_position],
		LoadAdRequest.RequestedAdSize.keys()[admob.banner_size],
		LoadAdRequest.CollapsiblePosition.keys()[admob.banner_collapsible_position]
	])

	var __request: LoadAdRequest = admob.create_banner_ad_request()
	__request.set_ad_unit_id(_get_banner_ad_unit_id(admob.banner_collapsible_position != LoadAdRequest.CollapsiblePosition.DISABLED))
	__request.set_anchor_to_safe_area(banner_anchor_at_safe_area_check_box.button_pressed)
	_is_banner_loading = true
	admob.load_banner_ad(__request)


func _on_size_button_pressed() -> void:
	if _is_banner_loaded():
		var __banner_ad_id: String = ad_id_option_button.get_item_text(ad_id_option_button.selected)
		print(" --- Get banner size button PRESSED --- ad id: %s" % __banner_ad_id)
		_print_to_screen("Banner size: " + str(admob.get_banner_dimension(__banner_ad_id)))


func _on_pixel_size_button_pressed() -> void:
	if _is_banner_loaded():
		var __banner_ad_id: String = ad_id_option_button.get_item_text(ad_id_option_button.selected)
		print(" --- Get banner pixel size button PRESSED --- ad id: %s" % __banner_ad_id)
		_print_to_screen("Banner size in pixels: " + str(admob.get_banner_dimension_in_pixels(__banner_ad_id)))


func _on_show_banner_button_pressed() -> void:
	if _is_banner_loaded():
		var __banner_ad_id: String = ad_id_option_button.get_item_text(ad_id_option_button.selected)
		print(" --- Show banner button PRESSED --- ad id: %s" % __banner_ad_id)
		admob.show_banner_ad(__banner_ad_id)


func _on_hide_banner_button_pressed() -> void:
	if _is_banner_loaded():
		var __banner_ad_id: String = ad_id_option_button.get_item_text(ad_id_option_button.selected)
		print(" --- Hide banner button PRESSED --- ad id: %s" % __banner_ad_id)
		admob.hide_banner_ad(__banner_ad_id)


func _on_remove_banner_button_pressed() -> void:
	if _is_banner_loaded():
		var __banner_ad_id: String = ad_id_option_button.get_item_text(ad_id_option_button.selected)
		print(" --- Remove banner button PRESSED --- ad id: %s" % __banner_ad_id)
		admob.remove_banner_ad(__banner_ad_id)
		ad_id_option_button.remove_item(ad_id_option_button.selected)
		if ad_id_option_button.item_count > 0:
			ad_id_option_button.select(ad_id_option_button.item_count-1)
		_update_banner_buttons()


func _on_interstitial_button_pressed() -> void:
	print(" ------- Interstitial button PRESSED")
	if _is_interstitial_loaded:
		_is_interstitial_loaded = false
		interstitial_button.disabled = true
		admob.show_interstitial_ad()
		reload_interstitial_button.disabled = false
	else:
		admob.load_interstitial_ad()


func _on_rewarded_video_button_pressed() -> void:
	print(" ------- Rewarded button PRESSED")
	if _is_rewarded_video_loaded:
		_is_rewarded_video_loaded = false
		rewarded_button.disabled = true
		admob.show_rewarded_ad()
		reload_rewarded_button.disabled = false
	else:
		admob.load_rewarded_ad()


func _on_rewarded_interstitial_button_pressed() -> void:
	print(" ------- Rewarded interstitial button PRESSED")
	if _is_rewarded_interstitial_loaded:
		_is_rewarded_interstitial_loaded = false
		rewarded_interstitial_button.disabled = true
		admob.show_rewarded_interstitial_ad()
		reload_rewarded_interstitial_button.disabled = false
	else:
		admob.load_rewarded_interstitial_ad()


func _on_reset_consent_button_pressed() -> void:
	_consent_status = UserConsent.status_to_string(UserConsent.Status.UNKNOWN)
	admob.reset_consent_info()


func _on_volume_h_slider_value_changed(value: float) -> void:
	volume_value_label.text = "%.2f" % value


func _on_get_settings_button_pressed() -> void:
	var __settings:= admob.get_global_settings()
	volume_hslider.value = __settings.get_ad_volume()
	muted_checkbutton.button_pressed = __settings.are_ads_muted()
	startup_checkbutton.button_pressed = __settings.get_apply_at_startup()
	_print_to_screen("Get global settings: volume=%.2f muted=%s apply_at_startup=%s" % [
			__settings.get_ad_volume(),
			str(__settings.are_ads_muted()),
			str(__settings.get_apply_at_startup())
	])


func _on_set_settings_button_pressed() -> void:
	var __settings:= (AdmobSettings.new()
			.set_ad_volume(volume_hslider.value)
			.set_ads_muted(muted_checkbutton.button_pressed)
			.set_apply_at_startup(startup_checkbutton.button_pressed))
	admob.set_global_settings(__settings)
	_print_to_screen("Set global settings: volume=%.2f muted=%s apply_at_startup=%s" % [
			__settings.get_ad_volume(),
			str(__settings.are_ads_muted()),
			str(__settings.get_apply_at_startup())
	])


func _on_admob_banner_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_is_banner_loading = false
	load_banner_button.disabled = false
	ad_id_option_button.add_item(ad_info.get_ad_id())
	_update_banner_buttons()
	_print_to_screen("%sbanner ad loaded by %s network (%s) id: %s" %
			["collapsible " if ad_info.get_is_collapsible() else "", response_info.get_network_tag(),
			response_info.get_adapter_class_name(), ad_info.get_ad_id()])


func _on_admob_banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_print_to_screen("%sbanner refreshed by %s network (%s) ad id: %s" %
			["collapsible " if ad_info.get_is_collapsible() else "", response_info.get_network_tag(),
			response_info.get_adapter_class_name(), ad_info.get_ad_id()])


func _on_admob_banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("banner %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	_is_banner_loading = false
	load_banner_button.disabled = false


func _on_admob_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_is_interstitial_loaded = true
	interstitial_button.disabled = false
	_print_to_screen("interstitial ad loaded by %s network (%s) id: %s" %
			[response_info.get_network_tag(), response_info.get_adapter_class_name(), ad_info.get_ad_id()])


func _on_admob_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("interstitial %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	reload_interstitial_button.disabled = false


func _on_admob_interstitial_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_print_to_screen("interstitial refreshed by %s network (%s) ad id: %s" %
			[response_info.get_network_tag(), response_info.get_adapter_class_name(), ad_info.get_ad_id()])


func _on_admob_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	_print_to_screen("interstitial closed: %s" % ad_info.get_ad_id())


func _on_admob_rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_is_rewarded_video_loaded = true
	rewarded_button.disabled = false
	_print_to_screen("rewarded video ad loaded by %s network (%s) id: %s" %
			[response_info.get_network_tag(), response_info.get_adapter_class_name(), ad_info.get_ad_id()])

	# Check all responses
	for __adapter_response in response_info.get_adapter_responses():
		_print_to_screen("Adapter '%s' - latency %d" % [
			__adapter_response.get_adapter_class_name(),
			__adapter_response.get_latency()
		])


func _on_admob_rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("rewarded video %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	reload_rewarded_button.disabled = true


func _on_admob_rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem) -> void:
	_print_to_screen("user rewarded for rewarded ad '%s' with %d %s" %
				[ad_info.get_ad_id(), reward_data.get_amount(), reward_data.get_type()])


func _on_admob_rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	_print_to_screen("rewarded ad dismissed: %s" % ad_info.get_ad_id())


func _on_admob_rewarded_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_is_rewarded_interstitial_loaded = true
	rewarded_interstitial_button.disabled = false
	_print_to_screen("rewarded interstitial ad loaded by %s network (%s) id: %s" %
			[response_info.get_network_tag(), response_info.get_adapter_class_name(), ad_info.get_ad_id()])


func _on_admob_rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("rewarded interstitial %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	reload_rewarded_interstitial_button.disabled = false


func _on_admob_rewarded_interstitial_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem) -> void:
	_print_to_screen("user rewarded for rewarded interstitial ad '%s' with %d %s" %
				[ad_info.get_ad_id(), reward_data.get_amount(), reward_data.get_type()])


func _on_admob_rewarded_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	_print_to_screen("rewarded interstitial ad dismissed: %s" % ad_info.get_ad_id())


func _on_admob_app_open_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	_print_to_screen("app open ad loaded by %s network (%s) id: %s" %
			[response_info.get_network_tag(), response_info.get_adapter_class_name(), ad_info.get_ad_id()])
	if not _is_app_open_ad_displayed_at_startup:
		admob.show_app_open_ad()


func _on_admob_app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("app open ad %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)


func _on_admob_app_open_ad_showed_full_screen_content(ad_info: AdInfo) -> void:
	_print_to_screen("app open showed full-screen content: %s" % ad_info.get_ad_id())
	_is_app_open_ad_displayed_at_startup = true


func _on_admob_app_open_ad_impression(ad_info: AdInfo) -> void:
	_print_to_screen("app open ad impression: %s" % ad_info.get_ad_id())
	_is_app_open_ad_displayed_at_startup = true


func _on_admob_app_open_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError) -> void:
	_print_to_screen("app open ad %s failed to show. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	_is_app_open_ad_displayed_at_startup = true
	admob.load_app_open_ad()


func _on_admob_app_open_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	_print_to_screen("app open dismissed: %s" % ad_info.get_ad_id())
	admob.load_app_open_ad()


func _on_admob_consent_info_updated() -> void:
	_print_to_screen("consent info updated")
	_process_consent_status(admob.get_consent_status())


func _on_admob_consent_info_update_failed(a_error_data: FormError) -> void:
	_print_to_screen("consent info failed to update: %s" % a_error_data.get_message())


func _process_consent_status(a_consent_status: UserConsent) -> void:
	_consent_status = a_consent_status.to_status_string()
	_print_to_screen("_process_consent_status(): consent status = %s" % _consent_status)
	match a_consent_status.status:
		UserConsent.Status.UNKNOWN:
			_print_to_screen("consent status is unknown")
			admob.update_consent_info()
		UserConsent.Status.NOT_REQUIRED:
			_print_to_screen("consent is not required")
			_load_ads()
		UserConsent.Status.REQUIRED:
			_print_to_screen("consent is required")
			admob.load_consent_form()
		UserConsent.Status.OBTAINED:
			_print_to_screen("consent has been obtained")
			admob.set_mediation_privacy_settings(NetworkPrivacySettings.new()
					.set_has_gdpr_consent(true)
					.set_is_age_restricted_user(false)
					.set_has_ccpa_sale_consent(true))
			_load_ads()


func _on_admob_consent_form_loaded() -> void:
	_print_to_screen("consent form has been loaded")
	admob.show_consent_form()


func _on_admob_consent_form_failed_to_load(a_error_data: FormError) -> void:
	_print_to_screen("consent form failed to load %s" % a_error_data.get_message())


func _on_admob_consent_form_dismissed(a_error_data: FormError) -> void:
	_print_to_screen("consent form has been dismissed %s" % a_error_data.get_message())
	_process_consent_status(admob.get_consent_status())


func _on_update_consent_info_button_pressed() -> void:
	admob.update_consent_info()


func _on_reload_interstitial_button_pressed() -> void:
	print(" ------- Reload interstitial button PRESSED")
	if _is_interstitial_loaded:
		_is_interstitial_loaded = false

	interstitial_button.disabled = true
	reload_interstitial_button.disabled = true
	admob.load_interstitial_ad()


func _on_reload_rewarded_button_pressed() -> void:
	print(" ------- Reload rewarded button PRESSED")
	if _is_rewarded_video_loaded:
		_is_rewarded_video_loaded = false

	rewarded_button.disabled = true
	reload_rewarded_button.disabled = true
	admob.load_rewarded_ad()


func _on_reload_rewarded_interstitial_button_pressed() -> void:
	print(" ------- Reload rewarded interstitial button PRESSED")
	if _is_rewarded_interstitial_loaded:
		_is_rewarded_interstitial_loaded = false

	rewarded_interstitial_button.disabled = true
	reload_rewarded_interstitial_button.disabled = true
	admob.load_rewarded_interstitial_ad()


func _get_banner_ad_unit_id(a_is_collapsible: bool) -> String:
	var __ad_unit_id = admob._banner_id

	if a_is_collapsible:
		if OS.has_feature("ios"):
			__ad_unit_id = "ca-app-pub-3940256099942544/8388050270"
		else:
			__ad_unit_id = "ca-app-pub-3940256099942544/6300978111"

	return __ad_unit_id


func _print_to_screen(a_message: String, a_is_error: bool = false) -> void:
	if a_is_error:
		_label.push_color(Color.CRIMSON)
	_label.add_text("%s\n\n" % a_message)
	if a_is_error:
		_label.pop()
		printerr("Demo app:: " + a_message)
	else:
		print("Demo app:: " + a_message)

	_label.scroll_to_line(_label.get_line_count() - 1)


func _is_native_ad_loaded() -> bool:
	return native_ad_id_option_button.item_count > 0


func _update_native_ad_buttons() -> void:
	if _is_native_ad_loaded():
		show_native_ad_button.disabled = false
		hide_native_ad_button.disabled = false
		attach_native_ad_button.disabled = false
		remove_native_ad_button.disabled = false
	else:
		show_native_ad_button.disabled = true
		hide_native_ad_button.disabled = true
		attach_native_ad_button.disabled = true
		remove_native_ad_button.disabled = true


func _on_load_native_ad_button_pressed() -> void:
	load_native_ad_button.disabled = true
	print(" --- Load native ad button PRESSED --- ")
	_is_native_ad_loading = true
	admob.load_native_ad()


func _on_show_native_ad_button_pressed() -> void:
	if _is_native_ad_loaded():
		var __native_ad_id: String = native_ad_id_option_button.get_item_text(native_ad_id_option_button.selected)
		print(" --- Show native ad button PRESSED --- ad id: %s" % __native_ad_id)
		admob.show_native_ad(__native_ad_id)


func _on_hide_native_ad_button_pressed() -> void:
	if _is_native_ad_loaded():
		var __native_ad_id: String = native_ad_id_option_button.get_item_text(native_ad_id_option_button.selected)
		print(" --- Hide native ad button PRESSED --- ad id: %s" % __native_ad_id)
		admob.hide_native_ad(__native_ad_id)


func _on_remove_native_ad_button_pressed() -> void:
	if _is_native_ad_loaded():
		var __native_ad_id: String = native_ad_id_option_button.get_item_text(native_ad_id_option_button.selected)
		print(" --- Remove native ad button PRESSED --- ad id: %s" % __native_ad_id)
		admob.remove_native_ad(__native_ad_id)
		native_ad_id_option_button.remove_item(native_ad_id_option_button.selected)
		if native_ad_id_option_button.item_count > 0:
			native_ad_id_option_button.select(native_ad_id_option_button.item_count-1)
		_update_native_ad_buttons()


func _on_admob_native_ad_loaded(ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	_is_native_ad_loading = false
	load_native_ad_button.disabled = false
	native_ad_id_option_button.add_item(ad_info.get_ad_id())
	_update_native_ad_buttons()
	_print_to_screen("native ad loaded id: %s" % ad_info.get_ad_id())


func _on_admob_native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	_print_to_screen("native %s failed to load. error: %d, message: %s" %
				[ad_info.get_ad_id(), error_data.get_code(), error_data.get_message()], true)
	_is_native_ad_loading = false
	load_native_ad_button.disabled = false


func _on_attach_native_ad_button_pressed() -> void:
	var __draggable_control := Control.new()
	__draggable_control.set_script(load("res://draggable_control.gd"))
	__draggable_control.custom_minimum_size = Vector2(250, 280)
	__draggable_control.top_level = true
	$CanvasLayer.add_child(__draggable_control)
	var __native_ad_id: String = native_ad_id_option_button.get_item_text(native_ad_id_option_button.selected)
	admob.attach_native_ad_to_control(__native_ad_id, __draggable_control)
