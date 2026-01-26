extends Control

var _dragging := false
var _drag_offset := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_drag_offset = event.position
				accept_event()
			else:
				_dragging = false

	elif event is InputEventMouseMotion and _dragging:
		global_position += event.relative
		accept_event()
