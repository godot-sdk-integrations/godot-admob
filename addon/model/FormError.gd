#
# © 2024-present https://github.com/cengiz-pz
#

class_name FormError extends RefCounted

const CODE_PROPERTY: String = "code"
const MESSAGE_PROPERTY: String = "message"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data if a_data else {}


func get_code() -> int:
	return _data[CODE_PROPERTY] if _data.has(CODE_PROPERTY) else 0


func get_message() -> String:
	return _data[MESSAGE_PROPERTY] if _data.has(MESSAGE_PROPERTY) else ""
