extends Control

var id = 0
var time = 0
var event_name = "":
	set(value):
		event_name = value
		$Button.text = event_name
var lane = 0

@onready var button = $Button
@onready var arrow = $Arrow
@onready var events = get_parent().chart_source.chart.events
@onready var chart_data_editor = get_parent().get_node("%EditorChartDataModifier")

var dragging = false
var pre_drag = false

var is_mouse_over = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: 
		if event.is_pressed() and is_mouse_over:
			pre_drag = true
		elif event.is_released():
			if dragging:
				events.sort_custom(chart_data_editor.sort_ascending)
				chart_data_editor.chart_loader.load_events()
			pre_drag = false
			dragging = false

func _process(_delta: float) -> void:
	var mouse_position = get_local_mouse_position()
	is_mouse_over = Rect2(Vector2.ZERO, $Button.size).has_point(mouse_position)
	if pre_drag and !is_mouse_over:
		pre_drag = false
		dragging = true
	
	if dragging:
		var move_pixel_count_y = mouse_position.y - (size.y / 2)
		move_pixel_count_y /= 64 * get_parent().scroll_zoom.value
		var beat = get_parent().song_audio_player.get_beat_from_seconds(events[id].time + move_pixel_count_y)
		beat = snapped(beat, 1.0 / get_parent().editor_snap.value)
		events[id].time = get_parent().song_audio_player.get_seconds_from_beat(beat)
		
		if mouse_position.x < 0:
			events[id].lane += 1
		
		if mouse_position.x > get_parent().event_lane_width:
			events[id].lane = max(events[id].lane - 1, 0)
		
		var max_lane_at_pos = -1
		var i = -1
		for event in events:
			i += 1
			if i == id:
				continue
			if abs(event.time - time) < 0.05:
				max_lane_at_pos = max(max_lane_at_pos, event.lane)
		events[id].lane = max(events[id].lane, max_lane_at_pos + 1)
		
		get_parent().update_event_positions()
	time = events[id].time
	lane = events[id].lane
