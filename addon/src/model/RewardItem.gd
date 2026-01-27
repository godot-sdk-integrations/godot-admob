#
# © 2024-present https://github.com/cengiz-pz
#

class_name RewardItem extends RefCounted

const AMOUNT_PROPERTY: String = "amount"
const TYPE_PROPERTY: String = "type"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_amount() -> int:
	return _data[AMOUNT_PROPERTY]


func get_type() -> String:
	return _data[TYPE_PROPERTY]
