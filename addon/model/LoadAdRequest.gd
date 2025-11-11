#
# © 2024-present https://github.com/cengiz-pz
#

class_name LoadAdRequest extends RefCounted

enum AdPosition {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
	CENTER
}

enum AdSize {
	BANNER,
	LARGE_BANNER,
	MEDIUM_RECTANGLE,
	FULL_BANNER,
	LEADERBOARD,
	SKYSCRAPER,
	FLUID
}

enum CollapsiblePosition {
	DISABLED, ## The banner ad will not be collapsible.
	TOP, ## The banner ad will be collapsible from bottom to top.
	BOTTOM ## The banner ad will be collapsible from top to bottom.
}

const COLLAPSIBLE_POSITION_NAMES: Dictionary = {
	CollapsiblePosition.TOP: "top",
	CollapsiblePosition.BOTTOM: "bottom",
}

const DATA_KEY_AD_UNIT_ID = "ad_unit_id"
const DATA_KEY_REQUEST_AGENT = "request_agent"
const DATA_KEY_AD_SIZE = "ad_size"
const DATA_KEY_AD_POSITION = "ad_position"
const DATA_KEY_KEYWORDS = "keywords"
const DATA_KEY_USER_ID = "user_id"
const DATA_KEY_COLLAPSIBLE_POSITION = "collapsible_position"
const DATA_KEY_CUSTOM_DATA = "custom_data"
const DATA_KEY_NETWORK_EXTRAS = "network_extras"

var _data: Dictionary


func _init() -> void:
	_data = {
		DATA_KEY_KEYWORDS: [],
		DATA_KEY_NETWORK_EXTRAS: []
	}


func set_ad_unit_id(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_AD_UNIT_ID] = a_value
	return self


func set_request_agent(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_REQUEST_AGENT] = a_value
	return self


func set_ad_size(a_value: AdSize) -> LoadAdRequest:
	_data[DATA_KEY_AD_SIZE] = AdSize.keys()[a_value]
	return self


func set_ad_position(a_value: AdPosition) -> LoadAdRequest:
	_data[DATA_KEY_AD_POSITION] = AdPosition.keys()[a_value]
	return self


func set_keywords(a_value: Array) -> LoadAdRequest:
	if a_value == null:
		_data[DATA_KEY_KEYWORDS] = []
	else:
		_data[DATA_KEY_KEYWORDS] = a_value
	return self


func add_keyword(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_KEYWORDS].append(a_value)
	return self


func set_user_id(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_USER_ID] = a_value
	return self


func set_collapsible_position(a_value: CollapsiblePosition) -> LoadAdRequest:
	if a_value != CollapsiblePosition.DISABLED:
		_data[DATA_KEY_COLLAPSIBLE_POSITION] =  COLLAPSIBLE_POSITION_NAMES[a_value]
	return self


func set_custom_data(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_CUSTOM_DATA] = a_value
	return self


func set_network_extras(a_value: Array) -> LoadAdRequest:
	if a_value == null:
		_data[DATA_KEY_NETWORK_EXTRAS] = []
	else:
		_data[DATA_KEY_NETWORK_EXTRAS] = a_value
	return self


func get_raw_data() -> Dictionary:
	return _data
