#
# © 2024-present https://github.com/cengiz-pz
#

class_name LoadAdRequest extends RefCounted

enum AdPosition {
	TOP, ## Ad will be anchored at the top of the screen.
	BOTTOM, ## Ad will be anchored at the bottom of the screen.
	LEFT, ## Ad will be anchored to the left of the screen.
	RIGHT, ## Ad will be anchored to the right of the screen.
	TOP_LEFT, ## Ad will be anchored at the top-left of the screen.
	TOP_RIGHT, ## Ad will be anchored at the top-right of the screen.
	BOTTOM_LEFT, ## Ad will be anchored at the bottom-left of the screen.
	BOTTOM_RIGHT, ## Ad will be anchored at the bottom-right of the screen.
	CENTER ## Ad will be anchored at the center of the screen.
}

enum AdSize {
	BANNER, ## A standard ad size that refers to a rectangular ad unit, most commonly 320x50 density-independent pixels (dp).
	LARGE_BANNER, ## A fixed-size banner with dimensions of 320x100 density-independent pixels (dp).
	MEDIUM_RECTANGLE, ## A standard 300x250 pixel ad, often referred to as the Interactive Advertising Bureau (IAB) medium rectangle.
	FULL_BANNER, ## An ad size constant for an Interactive Advertising Bureau (IAB) full-size banner, which has a fixed size of 468x60 density-independent pixels (dp).
	LEADERBOARD, ## A banner ad with dimensions of 728 pixels wide by 90 pixels tall. This is a standard display ad size that is designed for tablet screens. 
	SKYSCRAPER, ## Deprecated
	FLUID ## Deprecated
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
