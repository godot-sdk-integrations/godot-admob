class_name AdCache extends RefCounted

var limit: int
var label: String
var remove_ad_callable: Callable

var _ads: Dictionary[String, Object]
var _ad_queue: Array[String]


func _init(a_limit: int, a_label: String, a_callable: Callable) -> void:
	self.limit = a_limit
	self.label = a_label
	self.remove_ad_callable = a_callable

	_ads = {}
	_ad_queue = []

func is_empty() -> bool:
	return _ads.is_empty()

func has_key(a_key: String) -> bool:
	return _ads.has(a_key)

func last_key() -> String:
	return "" if _ad_queue.is_empty() else _ad_queue[0]

func all_keys() -> Array[String]:
	return _ads.keys()

func cache(a_ad_id: String, a_ad_data: Object) -> void:
	_ads[a_ad_id] = a_ad_data
	_ad_queue.push_front(a_ad_id)
	while _ads.size() > limit:
		Admob.log_warn("%s: %s cache size (%d) has exceeded maximum (%d)" % [Admob.PLUGIN_SINGLETON_NAME,
					label, _ads.size(), limit])
		remove_ad_callable.call(_erase_oldest())

func erase(a_ad_id: String) -> void:
	_ad_queue.erase(a_ad_id)
	_ads.erase(a_ad_id)

func erase_last() -> String:
	var __removed_ad_id: String = _ad_queue.pop_front()
	_ads.erase(__removed_ad_id)
	return __removed_ad_id

func _erase_oldest() -> String:
	var __removed_ad_id: String = _ad_queue.pop_back()
	_ads.erase(__removed_ad_id)
	return __removed_ad_id
