class_name SpinSlider extends Range

@export var prefix = ""
@export var show_range = false
@export var suffix = ""

var dragging = false
var drag_position = null
var distance_from_next_step = 0.0

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
			dragging = false
		else:
			editing = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
		var mouse_position = get_local_mouse_position()
		var is_mouse_over = Rect2(Vector2.ZERO, size).has_point(mouse_position)
		if event.is_pressed() and is_mouse_over and !editing:
			dragging = true
			drag_position = mouse_position
		
		if event.is_pressed() and !is_mouse_over and editing:
			editing = false
		
		if event.is_released():
			dragging = false
	
	if event is InputEventMouseMotion and dragging:
		var spin_range = max_value - min_value
		
		if step == 0.0:
			value += event.screen_relative.x * 0.003 * spin_range
		else:
			distance_from_next_step += event.screen_relative.x * 0.003 * spin_range
			if abs(distance_from_next_step) > step:
				var value_moved = snapped(distance_from_next_step, step)
				value += value_moved
				distance_from_next_step -= value_moved
	
	if editing and event is InputEventKey and event.is_pressed():
		var key_pressed = OS.get_keycode_string(event.key_label)
		print(key_pressed)
		match key_pressed:
			"Left":
				caret_position = max(caret_position - 1, 0)
			"Right":
				caret_position = min(caret_position + 1, len(str(value)))
			"Backspace":
				var old_length = len(str(value))
				var erase_position = max(caret_position - 1, 0)
				value = float(str(value).erase(erase_position))
				if old_length != len(str(value)):
					caret_position -= 1
			_:
				if key_pressed.is_valid_int():
					var old_length = len(str(value))
					value = float(str(value).insert(caret_position, key_pressed))
					if old_length != len(str(value)):
						caret_position += 1
	
	if editing and event.is_action_pressed("ui_copy"):
		DisplayServer.clipboard_set(str(value))
	
	if editing and event.is_action_pressed("ui_paste"):
		var clipboard = DisplayServer.clipboard_get()
		if clipboard.is_valid_float():
			value = float(clipboard)

func _draw() -> void:
	var string = str(value)
	
	var back = get_theme_stylebox("normal", "LineEdit")
	var back_focus = get_theme_stylebox("focus", "LineEdit")
	var font = get_theme_font("font", "LineEdit")
	draw_style_box(back, Rect2(Vector2.ZERO, size))
	var font_height = font.get_height() / 2.0
	var left_margin = back.get_content_margin(SIDE_LEFT)
	var font_y = (font_height + size.y) / 2
	draw_string(font, Vector2(left_margin, font_y), prefix + string + suffix)
	if editing:
		draw_style_box(back_focus, Rect2(Vector2.ZERO, size))
		var caret_x = font.get_string_size(prefix + string.substr(0, caret_position)).x
		var caret_y = font.get_ascent()
		var caret_height = font.get_height()
		draw_rect(Rect2(left_margin + caret_x, font_y - caret_y, 2, caret_height), Color.WHITE)
	if !show_range:
		return
	
	var right_margin = back.get_content_margin(SIDE_LEFT)
	var bottom_margin = back.get_content_margin(SIDE_BOTTOM)
	var height = 2
	var width = size.x - (left_margin + right_margin)
	draw_rect(
		Rect2(left_margin, size.y - bottom_margin - height, width, height),
		Color(Color.WHITE, 0.2)
	)
	var percent = remap(value, min_value, max_value, 0.0, 1.0)
	var percent_clamped = clamp(percent, 0.0, 1.0)
	var overflow = percent - percent_clamped
	height = 3
	draw_rect(
		Rect2(left_margin, size.y - bottom_margin - height, width * percent_clamped, height),
		Color(Color.WHITE, 0.5)
	)
	if overflow == 0:
		return
	var overflow_transparency = 0.25
	var flip = false
	if overflow < 0:
		overflow *= -1
		flip = true
	
	var overflow_remainder = overflow - floor(overflow)
	var overflow_background_count = floor(overflow)
	if overflow_background_count > 0.0:
		var overflow_background_transparency = 1.0 - pow(1.0 - overflow_transparency, overflow_background_count)
		draw_rect(
			Rect2(left_margin, size.y - bottom_margin - height, width, height),
			Color(Color.RED, overflow_background_transparency)
		)
	var left_position = left_margin
	var overflow_width = width * overflow_remainder
	if flip:
		left_position += (width - overflow_width)
	draw_rect(
		Rect2(left_position, size.y - bottom_margin - height, overflow_width, height),
		Color(Color.RED, overflow_transparency)
	)
