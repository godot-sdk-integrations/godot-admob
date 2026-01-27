#
# © 2026-present https://github.com/cengiz-pz
#

class_name AdmobSettings extends RefCounted

const DATA_KEY_AD_VOLUME = "ad_volume"
const DATA_KEY_ADS_MUTED = "ads_muted"
const DATA_KEY_APPLY_AT_STARTUP = "apply_at_startup"

var _data: Dictionary


func _init(a_data: Dictionary = {}) -> void:
	_data = a_data


func set_ad_volume(a_value: float) -> AdmobSettings:
	_data[DATA_KEY_AD_VOLUME] = a_value
	return self


func get_ad_volume() -> float:
	return _data[DATA_KEY_AD_VOLUME]


func set_ads_muted(a_value: bool) -> AdmobSettings:
	_data[DATA_KEY_ADS_MUTED] = a_value
	return self


func are_ads_muted() -> bool:
	return _data[DATA_KEY_ADS_MUTED]


func set_apply_at_startup(a_value: bool) -> AdmobSettings:
	_data[DATA_KEY_APPLY_AT_STARTUP] = a_value
	return self


func get_apply_at_startup() -> bool:
	return _data[DATA_KEY_APPLY_AT_STARTUP]


func get_raw_data() -> Dictionary:
	return _data
