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
	CENTER, ## Ad will be anchored at the center of the screen.
	CUSTOM ## Ad position will be set dynamically.
}

enum RequestedAdSize {
	BANNER, ## A standard ad size that refers to a rectangular ad unit, most commonly 320x50 density-independent pixels (dp).
	LARGE_BANNER, ## A fixed-size banner with dimensions of 320x100 density-independent pixels (dp).
	MEDIUM_RECTANGLE, ## A standard 300x250 pixel ad, often referred to as the Interactive Advertising Bureau (IAB) medium rectangle.
	FULL_BANNER, ## An ad size constant for an Interactive Advertising Bureau (IAB) full-size banner, which has a fixed size of 468x60 density-independent pixels (dp).
	LEADERBOARD, ## A banner ad with dimensions of 728 pixels wide by 90 pixels tall. This is a standard display ad size that is designed for tablet screens.
	ADAPTIVE, ## An ad that automatically adjusts its width and height to fit the device’s available screen space, providing the best-performing banner size for that specific layout.
	INLINE_ADAPTIVE, ## An ad that dynamically optimizes its height for the available inline content width, ensuring a smoothly integrated banner that fits naturally within scrollable or in-feed layouts.
	SKYSCRAPER, ## Deprecated
	FLUID, ## Deprecated
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
const DATA_KEY_ADAPTIVE_WIDTH = "adaptive_width"
const DATA_KEY_ADAPTIVE_MAX_HEIGHT = "adaptive_max_height"
const DATA_KEY_AD_POSITION = "ad_position"
const DATA_KEY_COLLAPSIBLE_POSITION = "collapsible_position"
const DATA_KEY_ANCHOR_TO_SAFE_AREA = "anchor_to_safe_area"
const DATA_KEY_KEYWORDS = "keywords"
const DATA_KEY_USER_ID = "user_id"
const DATA_KEY_CUSTOM_DATA = "custom_data"
const DATA_KEY_NETWORK_EXTRAS = "network_extras"

const DEFAULT_DATA: Dictionary = {
	DATA_KEY_KEYWORDS: [],
	DATA_KEY_NETWORK_EXTRAS: []
}

var _data: Dictionary


func _init(a_data: Dictionary = DEFAULT_DATA.duplicate()) -> void:
	_data = a_data


func set_ad_unit_id(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_AD_UNIT_ID] = a_value
	return self


func get_ad_unit_id() -> String:
	return _data[DATA_KEY_AD_UNIT_ID]


func set_request_agent(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_REQUEST_AGENT] = a_value
	return self


func get_request_agent() -> String:
	return _data[DATA_KEY_REQUEST_AGENT]


func set_ad_size(a_value: RequestedAdSize) -> LoadAdRequest:
	_data[DATA_KEY_AD_SIZE] = RequestedAdSize.keys()[a_value]
	return self


func get_ad_size() -> RequestedAdSize:
	return RequestedAdSize[_data[DATA_KEY_AD_SIZE]] if _data.has(DATA_KEY_AD_SIZE) else RequestedAdSize.BANNER


func set_adaptive_width(a_value: int) -> LoadAdRequest:
	_data[DATA_KEY_ADAPTIVE_WIDTH] = a_value
	return self


func get_adaptive_width() -> int:
	return _data[DATA_KEY_ADAPTIVE_WIDTH]


func set_adaptive_max_height(a_value: int) -> LoadAdRequest:
	_data[DATA_KEY_ADAPTIVE_MAX_HEIGHT] = a_value
	return self


func get_adaptive_max_height() -> int:
	return _data[DATA_KEY_ADAPTIVE_MAX_HEIGHT]


func set_ad_position(a_value: AdPosition) -> LoadAdRequest:
	_data[DATA_KEY_AD_POSITION] = AdPosition.keys()[a_value]
	return self


func get_ad_position() -> AdPosition:
	return AdPosition[_data[DATA_KEY_AD_POSITION]] if _data.has(DATA_KEY_AD_POSITION) else AdPosition.CUSTOM


func set_collapsible_position(a_value: CollapsiblePosition) -> LoadAdRequest:
	if a_value != CollapsiblePosition.DISABLED:
		_data[DATA_KEY_COLLAPSIBLE_POSITION] = COLLAPSIBLE_POSITION_NAMES[a_value]
	return self


func get_collapsible_position() -> CollapsiblePosition:
	return CollapsiblePosition[_data[DATA_KEY_COLLAPSIBLE_POSITION]] if _data.has(DATA_KEY_COLLAPSIBLE_POSITION) else CollapsiblePosition.DISABLED


func set_anchor_to_safe_area(a_value: bool) -> LoadAdRequest:
	_data[DATA_KEY_ANCHOR_TO_SAFE_AREA] = a_value
	return self


func get_anchor_to_safe_area() -> bool:
	return _data[DATA_KEY_ANCHOR_TO_SAFE_AREA] if _data.has(DATA_KEY_ANCHOR_TO_SAFE_AREA) else false


func set_keywords(a_value: Array) -> LoadAdRequest:
	if a_value == null:
		_data[DATA_KEY_KEYWORDS] = []
	else:
		_data[DATA_KEY_KEYWORDS] = a_value
	return self


func add_keyword(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_KEYWORDS].append(a_value)
	return self


func get_keywords() -> Array:
	return _data[DATA_KEY_KEYWORDS] if _data.has(DATA_KEY_KEYWORDS) else []


func set_user_id(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_USER_ID] = a_value
	return self


func get_user_id() -> String:
	return _data[DATA_KEY_USER_ID] if _data.has(DATA_KEY_USER_ID) else ""


func set_custom_data(a_value: String) -> LoadAdRequest:
	_data[DATA_KEY_CUSTOM_DATA] = a_value
	return self


func get_custom_data() -> String:
	return _data[DATA_KEY_CUSTOM_DATA] if _data.has(DATA_KEY_CUSTOM_DATA) else ""


func set_network_extras(a_value: Array) -> LoadAdRequest:
	if a_value == null:
		_data[DATA_KEY_NETWORK_EXTRAS] = []
	else:
		_data[DATA_KEY_NETWORK_EXTRAS] = a_value
	return self


func get_network_extras() -> Array:
	return _data[DATA_KEY_NETWORK_EXTRAS] if _data.has(DATA_KEY_NETWORK_EXTRAS) else []


func get_raw_data() -> Dictionary:
	return _data
