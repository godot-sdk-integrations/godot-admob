#
# © 2024-present https://github.com/cengiz-pz
#

class_name InlineAdaptiveBanner extends Control


const MINIMUM_VALID_WIDTH: float = 50.0
const MINIMUM_CLIP_THRESHOLD: float = 0.05
const MAXIMUM_CLIP_THRESHOLD: float = 1.0
const MINIMUM_RESIZE_THRESHOLD: float = 10.0
const MAXIMUM_RESIZE_THRESHOLD: float = 500.0

## Maximum pixel height of the requested ad. If set to -1, height will be automatically determined.
@export var max_ad_height: int = -1

## Minimum portion of the banner’s area (as a percentage) that must be clipped before the banner is considered hidden.
@export_range(MINIMUM_CLIP_THRESHOLD, MAXIMUM_CLIP_THRESHOLD, 0.05) var clip_threshold: float = 0.1:
	set(a_value):
		clip_threshold = clampf(a_value, MINIMUM_CLIP_THRESHOLD, MAXIMUM_CLIP_THRESHOLD)

## Width-change threshold (in pixels) that triggers a banner reload when the ad container is resized by this amount or more.
@export_range(MINIMUM_RESIZE_THRESHOLD, MAXIMUM_RESIZE_THRESHOLD, 5.0) var resize_threshold: float = 50.0:
	set(a_value):
		resize_threshold = clampf(a_value, MINIMUM_RESIZE_THRESHOLD, MAXIMUM_RESIZE_THRESHOLD)

## Path to Admob node.
@export_node_path("Admob") var admob_path: NodePath

## Whether the inline-adaptive banner ad should be automatically loaded.
@export var auto_load: bool = false

@export_category("Ad Unit Identifier")
## Use ad unit identifier value defined in the Admob node.
@export var inherit_from_admob_node: bool = false

@export_group("Android", "ad_unit_id_android")
## Ad unit ID of the inline adaptive banner ad to be loaded on the Android platform.
@export var ad_unit_id_android_debug: String = "ca-app-pub-3940256099942544/2014213617"

## Ad unit ID of the inline adaptive banner ad to be loaded on the Android platform.
@export var ad_unit_id_android_real: String = ""

@export_group("iOS", "ad_unit_id_ios")
## Ad unit ID of the inline adaptive banner ad to be loaded on the iOS platform.
@export var ad_unit_id_ios_debug: String = "ca-app-pub-3940256099942544/2934735716"

## Ad unit ID of the inline adaptive banner ad to be loaded on the iOS platform.
@export var ad_unit_id_ios_real: String = ""

var admob: Admob
var _ad_unit_id: String
var ad_id: String = ""

var last_width: float

var pending_load: bool = false
var is_position_dirty: bool = false
var is_banner_visible: bool = false
var do_ignore_resize: bool = false

func _enter_tree() -> void:
	var __admob: Admob
	if admob_path:
		__admob = get_node(admob_path)

	if __admob:
		initialize(__admob)
	else:
		push_warning("Admob node not found")

func _exit_tree() -> void:
	if ad_id != "":
		remove_ad()

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	size_flags_vertical = Control.SIZE_SHRINK_CENTER

	last_width = size.x
	resized.connect(_on_resized)

func initialize(a_admob_node: Admob) -> void:
	admob = a_admob_node

	visibility_changed.connect(_on_visibility_changed)
	admob.banner_ad_loaded.connect(_on_banner_ad_loaded)
	admob.banner_ad_failed_to_load.connect(_on_banner_ad_failed_to_load)
	admob.banner_ad_refreshed.connect(_on_banner_ad_refreshed)
	admob.banner_ad_size_measured.connect(_on_banner_ad_size_measured)

	if admob.is_initialization_completed:
		if auto_load:
			call_deferred("_deferred_load_ad")
	else:
		admob.initialization_completed.connect(_on_Admob_initialization_completed)

	if inherit_from_admob_node:
		_ad_unit_id = admob._banner_id
	else:
		if OS.has_feature("ios"):
			if admob.is_real:
				_ad_unit_id = ad_unit_id_ios_real
			else:
				_ad_unit_id = ad_unit_id_ios_debug
		else:
			if admob.is_real:
				_ad_unit_id = ad_unit_id_android_real
			else:
				_ad_unit_id = ad_unit_id_android_debug

func _deferred_load_ad() -> void:
	load_ad()
	_mark_position_dirty()

# --------------------------------------------------------------
# AD MANIPULATION
# --------------------------------------------------------------

func load_ad() -> void:
	if _ad_unit_id == "":
		return

	var req := LoadAdRequest.new()
	req.set_ad_unit_id(_ad_unit_id)
	req.set_ad_size(LoadAdRequest.RequestedAdSize.INLINE_ADAPTIVE)

	if custom_minimum_size.x < MINIMUM_VALID_WIDTH:
		admob.log_warn("Can't load ad. Invalid inline adaptive banner width: %.1f" % custom_minimum_size.x)
		return

	req.set_adaptive_width(round(custom_minimum_size.x))

	if max_ad_height != -1:
		req.set_adaptive_max_height(max_ad_height)

	req.set_ad_position(LoadAdRequest.AdPosition.CUSTOM)

	pending_load = true
	admob.load_banner_ad(req)

func show_ad() -> void:
	if not is_banner_visible:
		admob.show_banner_ad(ad_id)
		is_banner_visible = true

func hide_ad() -> void:
	if is_banner_visible:
		admob.hide_banner_ad(ad_id)
		is_banner_visible = false

func move_ad(a_physical_position: Vector2) -> void:
	admob.move_banner_ad(ad_id, a_physical_position.x, a_physical_position.y)

func remove_ad() -> void:
	admob.remove_banner_ad(ad_id)
	is_banner_visible = false
	ad_id = ""

# --------------------------------------------------------------
# POSITIONING
# --------------------------------------------------------------

func _process(_delta: float) -> void:
	if is_position_dirty:
		_deferred_update_position()
		is_position_dirty = false
	else:
		update_banner_position()

func _mark_position_dirty() -> void:
	is_position_dirty = true
	call_deferred("_deferred_update_position")

func _deferred_update_position() -> void:
	update_banner_position()

func update_banner_position() -> void:
	if ad_id == "":
		return

	# Check basic tree visibility (Tabs, hidden parents)
	if not is_visible_in_tree():
		hide_ad()
		return

	 # Smart clipping (visibility logic)
	var is_clipped_out: bool = false

	if size.x > 1.0 and size.y > 1.0:
		var virtual_rect := get_global_rect()
		var original_area := virtual_rect.get_area()
		var visible_region := virtual_rect
		var parent = get_parent()

		# Walk up the tree to find ScrollContainers or other clippers
		while parent is Control:
			if parent.clip_contents:
				var parent_rect: Rect2 = parent.get_global_rect()
				var intersection := visible_region.intersection(parent_rect)

				# No intersection → fully clipped (100%)
				if intersection.get_area() <= 0:
					is_clipped_out = true
					break

				visible_region = intersection
			parent = parent.get_parent()

		# Final check
		if not get_viewport_rect().intersects(virtual_rect):
			is_clipped_out = true
		else:
			# Calculate the percentage clipped
			var visible_area := visible_region.get_area()
			var clipped_ratio := 1.0 - (visible_area / original_area)

			if clipped_ratio >= clip_threshold:
				is_clipped_out = true

	if is_clipped_out:
		if is_banner_visible:
			hide_ad()
	else:
		if not is_banner_visible:
			show_ad()

		move_ad(_godot_to_physical(global_position))

# --------------------------------------------------------------
# SIGNAL HANDLERS
# --------------------------------------------------------------

func _on_Admob_initialization_completed(_status: InitializationStatus) -> void:
	if auto_load:
		call_deferred("_deferred_load_ad")

func _on_resized() -> void:
	if ad_id == "":
		return

	if do_ignore_resize:
		do_ignore_resize = false
		return

	if abs(size.x - last_width) < resize_threshold:
		return

	last_width = size.x
	remove_ad()
	call_deferred("_deferred_load_ad")

	_mark_position_dirty()

func _on_visibility_changed() -> void:
	if ad_id != "":
		if is_visible_in_tree():
			show_ad()
		else:
			hide_ad()

func _on_banner_ad_loaded(loaded_ad_info: AdInfo, _response: ResponseInfo) -> void:
	if !pending_load:
		return

	if loaded_ad_info.get_load_ad_request().get_ad_size() != LoadAdRequest.RequestedAdSize.INLINE_ADAPTIVE:
		return

	if loaded_ad_info.get_load_ad_request().get_ad_unit_id().casecmp_to(_ad_unit_id) != 0:
		return

	pending_load = false
	ad_id = loaded_ad_info.get_ad_id()

	_apply_loaded_size(Vector2(loaded_ad_info.get_measured_width(), loaded_ad_info.get_measured_height()))
	_mark_position_dirty()

func _on_banner_ad_failed_to_load(failed_ad_info: AdInfo, _err: LoadAdError) -> void:
	if failed_ad_info.get_load_ad_request().get_ad_size() != LoadAdRequest.RequestedAdSize.INLINE_ADAPTIVE:
		return

	if failed_ad_info.get_load_ad_request().get_ad_unit_id().casecmp_to(_ad_unit_id) != 0:
		return

	if pending_load:
		pending_load = false

func _on_banner_ad_size_measured(ad_info: AdInfo) -> void:
	if ad_info.get_ad_id().casecmp_to(ad_id) == 0:
		_apply_loaded_size(Vector2(ad_info.get_measured_width(), ad_info.get_measured_height()))

func _on_banner_ad_refreshed(refreshed_ad_info: AdInfo, _response: ResponseInfo) -> void:
	if refreshed_ad_info.get_ad_id().casecmp_to(ad_id) == 0:
		hide_ad()	# Prevent ad from briefly displaying out of position
		_apply_loaded_size(Vector2(refreshed_ad_info.get_measured_width(), refreshed_ad_info.get_measured_height()))
		_mark_position_dirty()

# --------------------------------------------------------------
# UTILITY
# --------------------------------------------------------------

func _apply_loaded_size(a_size: Vector2) -> void:
	do_ignore_resize = true

	custom_minimum_size = a_size
	size = a_size

func _calculate_scale_factor() -> Vector2:
	var screen_size: Vector2 = DisplayServer.window_get_size() as Vector2
	var virtual_size: Vector2 = get_viewport().get_visible_rect().size
	return screen_size / virtual_size

func _physical_to_godot(a_physical_size: Vector2) -> Vector2:
	return a_physical_size / _calculate_scale_factor()

func _godot_to_physical(a_godot_size: Vector2) -> Vector2:
	return a_godot_size * _calculate_scale_factor()
