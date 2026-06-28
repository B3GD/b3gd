extends Control

@onready var chart_data_modifier := %EditorChartDataModifier

var time = 1
var lane = 1

var is_mouse_over = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		$EditorEventClassBox.disabled = false
		if !$EditorEventClassBox.is_hovered():
			$EditorEventClassBox.disabled = true
		#if !$EditorEventClassBox.get_popup().visible:
		#	$EditorEventClassBox.show_popup()

func _process(delta: float) -> void:
	var mouse_position = get_parent().get_local_mouse_position()
	var is_mouse_over = Rect2(Vector2.ZERO, get_parent().size).has_point(mouse_position)
	
	if !$EditorEventClassBox.disabled:
		return
	
	if !is_mouse_over:
		hide()
		return
	else:
		show()
	
	var downscroll = get_parent().downscroll_toggle.button_pressed
	var time_mouse_pos = mouse_position.y
	var size_percent = get_parent().size.y * (0.5 + (remap(float(downscroll), 0, 1, 1, -1) * (%EditorStrumLineContainer.timeline_present_point - 0.5)))
	time_mouse_pos -= size_percent
	var scroll_mult = get_parent().scroll_zoom.value
	if downscroll:
		scroll_mult *= -1.0
	
	time_mouse_pos /= 64 * scroll_mult
	time_mouse_pos += get_parent().song_audio_player.song_progress_seconds
	time_mouse_pos = %EditorChartDataModifier.get_snapped_time(time_mouse_pos)
	time = time_mouse_pos


func _on_editor_event_class_box_item_selected(index: int) -> void:
	chart_data_modifier.add_event(time)
