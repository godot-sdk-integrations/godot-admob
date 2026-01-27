#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdError extends RefCounted

const CODE_PROPERTY: String = "code"
const DOMAIN_PROPERTY: String = "domain"
const MESSAGE_PROPERTY: String = "message"
const CAUSE_PROPERTY: String = "cause"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_code() -> int:
	return _data[CODE_PROPERTY]


func get_domain() -> String:
	return _data[DOMAIN_PROPERTY]


func get_message() -> String:
	return _data[MESSAGE_PROPERTY]


func get_cause() -> AdError:
	return AdError.new(_data[CAUSE_PROPERTY]) if _data.has(CAUSE_PROPERTY) else null
