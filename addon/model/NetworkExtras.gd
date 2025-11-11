#
# © 2024-present https://github.com/cengiz-pz
#

class_name NetworkExtras extends Resource


const NETWORK_TAG_PROPERTY: String = "network_tag"
const EXTRAS_PROPERTY: String = "extras"


## Identifies the target ad network for the extras.
@export var network_flag: MediationNetwork.Flag = MediationNetwork.Flag.APPLOVIN

## Dictionary holding one or more extras. Only keys of type String are allowed. Values can be String, int, or bool.
@export var extras: Dictionary


func get_raw_data() -> Dictionary:
	var __network: MediationNetwork = MediationNetwork.get_by_flag(network_flag)
	var __raw_data: Dictionary

	__raw_data = {NETWORK_TAG_PROPERTY: __network.tag, EXTRAS_PROPERTY: extras}

	return __raw_data


static func build_raw_data_array(a_network_extras: Array[NetworkExtras]) -> Array:
	var __raw_data_array: Array[Dictionary] = []

	for __network_extras in a_network_extras:
		__raw_data_array.append(__network_extras.get_raw_data())

	return __raw_data_array
