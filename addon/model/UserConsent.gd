#
# © 2024-present https://github.com/cengiz-pz
#

class_name UserConsent extends RefCounted

enum Status {
	UNKNOWN,
	NOT_REQUIRED,
	REQUIRED,
	OBTAINED
}

var status: Status

func _init(a_status_string: String = "") -> void:
	if a_status_string == "":
		status = Status.UNKNOWN
	else:
		status = string_to_status(a_status_string)

func to_status_string() -> String:
	return Status.keys()[status]

static func status_to_string(a_status: Status) -> String:
	return Status.keys()[a_status]

static func string_to_status(a_string: String) -> Status:
	return Status.get(a_string)
