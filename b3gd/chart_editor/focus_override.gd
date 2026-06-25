extends Control
# FOCUS IN GODOT REALLY PISSES ME OFF

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		print("yeah")
		get_viewport().set_input_as_handled()
