#
# © 2024-present https://github.com/cengiz-pz
#

class_name NetworkExtras extends Resource


const ADAPTER_CLASS_PROPERTY: String = "adapter_class"
const EXTRAS_PROPERTY: String = "extras"


@export var network_flag: MediationNetwork.Flag = MediationNetwork.Flag.APPLOVIN
@export var extras: Dictionary


func get_raw_data() -> Dictionary:
	var __network: MediationNetwork = MediationNetwork.get_by_flag(network_flag)
	var __raw_data: Dictionary

	if OS.has_feature("ios"):
		__raw_data = {ADAPTER_CLASS_PROPERTY: __network.ios_adapter_class, EXTRAS_PROPERTY: extras}
	else:
		__raw_data = {ADAPTER_CLASS_PROPERTY: __network.android_adapter_class, EXTRAS_PROPERTY: extras}

	return __raw_data


static func build_raw_data_array(a_network_extras: Array[NetworkExtras]) -> Array:
	var __raw_data_array: Array[Dictionary] = []

	for __network_extras in a_network_extras:
		__raw_data_array.append(__network_extras.get_raw_data())

	return __raw_data_array
