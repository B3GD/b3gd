class_name LineEditNoFocus extends Control

signal text_changed(new_text)

@export var text = "":
	set(value):
		text = value
		text_changed.emit(value)

var editing = false:
	set(value):
		editing = value
		if editing:
			caret_position = len(str(value)) - 1
		queue_redraw()
var caret_position = 0:
	set(value):
		caret_position = value
		queue_redraw()

func _ready() -> void:
	focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
	custom_minimum_size.y = 32

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		if !editing:
			editing = true
		else:
			editing = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		var mouse_position = get_local_mouse_position()
		var is_mouse_over = Rect2(Vector2.ZERO, size).has_point(mouse_position)
		
		if event.is_pressed() and !is_mouse_over and editing:
			editing = false
	
	if editing and event is InputEventKey and event.is_pressed():
		var key_pressed = OS.get_keycode_string(event.key_label)
		print(key_pressed)
		match key_pressed:
			"Left":
				caret_position = max(caret_position - 1, 0)
			"Right":
				caret_position = min(caret_position + 1, len(text))
			"Backspace":
				var old_length = len(text)
				var erase_position = max(caret_position - 1, 0)
				text = text.erase(erase_position)
				if old_length != len(text):
					caret_position -= 1
			_:
				if key_pressed.is_valid_int():
					var old_length = len(text)
					text = text.insert(caret_position, key_pressed)
					if old_length != len(text):
						caret_position += 1
	
	if event.is_action_pressed("ui_copy"):
		DisplayServer.clipboard_set(text)
	
	if event.is_action_pressed("ui_paste"):
		text = DisplayServer.clipboard_get()

func _draw() -> void:
	var back = get_theme_stylebox("normal", "LineEdit")
	var back_focus = get_theme_stylebox("focus", "LineEdit")
	var font = get_theme_font("font", "LineEdit")
	draw_style_box(back, Rect2(Vector2.ZERO, size))
	var font_height = font.get_height() / 2.0
	var left_margin = back.get_content_margin(SIDE_LEFT)
	var font_y = (font_height + size.y) / 2
	draw_string(font, Vector2(left_margin, font_y), text)
	if editing:
		draw_style_box(back_focus, Rect2(Vector2.ZERO, size))
		var caret_x = font.get_string_size(text.substr(0, caret_position)).x
		var caret_y = font.get_ascent()
		var caret_height = font.get_height()
		draw_rect(Rect2(left_margin + caret_x, font_y - caret_y, 2, caret_height), Color.WHITE)
