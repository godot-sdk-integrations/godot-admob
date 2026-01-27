#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdSize extends RefCounted

const WIDTH_PROPERTY: String = "width"
const HEIGHT_PROPERTY: String = "height"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data if a_data else {}


func get_width() -> int:
	return _data[WIDTH_PROPERTY] if _data.has(WIDTH_PROPERTY) else 0


func get_height() -> int:
	return _data[HEIGHT_PROPERTY] if _data.has(HEIGHT_PROPERTY) else 0
