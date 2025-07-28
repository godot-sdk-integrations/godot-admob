#
# © 2024-present https://github.com/cengiz-pz
#

class_name ConsentInformation extends RefCounted


# https://developers.google.com/admob/android/reference/privacy/com/google/android/ump/ConsentInformation.ConsentStatus
enum ConsentStatus {
	UNKNOWN = 0,
	NOT_REQUIRED = 1,
	REQUIRED = 2,
	OBTAINED = 3
}
