#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdInfo extends RefCounted

const AD_ID_PROPERTY: String = "ad_id"
const MEASURED_WIDTH_PROPERTY: String = "measured_width"
const MEASURED_HEIGHT_PROPERTY: String = "measured_height"
const IS_COLLAPSIBLE_PROPERTY: String = "is_collapsible"
const LOAD_AD_REQUEST_PROPERTY: String = "load_ad_request"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_ad_id() -> String:
	return _data[AD_ID_PROPERTY] if _data.has(AD_ID_PROPERTY) else ""


func get_measured_width() -> int:
	return _data[MEASURED_WIDTH_PROPERTY] if _data.has(MEASURED_WIDTH_PROPERTY) else 0


func get_measured_height() -> int:
	return _data[MEASURED_HEIGHT_PROPERTY] if _data.has(MEASURED_HEIGHT_PROPERTY) else 0


func get_is_collapsible() -> bool:
	return _data[IS_COLLAPSIBLE_PROPERTY] if _data.has(IS_COLLAPSIBLE_PROPERTY) else false


func get_load_ad_request() -> LoadAdRequest:
	return LoadAdRequest.new(_data[LOAD_AD_REQUEST_PROPERTY]) if _data.has(LOAD_AD_REQUEST_PROPERTY) else null
