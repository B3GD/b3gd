extends Control

@export var event_selected = -1

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")

@export var event_box_scene: PackedScene
@export var event_lane_width: int

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var scroll_zoom = %EditorScrollZoom
@onready var downscroll_toggle = %EditorDownscroll
@onready var strum_line_container = %EditorStrumLineContainer
@onready var editor_snap = %EditorSnap

func _ready() -> void:
	get_selection()
	update_events()
	update_event_positions()

func get_selection():
	var previous_selected = event_selected
	event_selected = -1
	
	var unselect_previous = false
	
	for i in get_children().size():
		var event_box = get_children()[i]
		if event_box.get_node("Button").button_pressed:
			event_selected = i
			if i != previous_selected:
				unselect_previous = true
	if unselect_previous:
		get_children()[previous_selected].get_node("Button").button_pressed = false

func update_events():
	for child in get_children():
		remove_child(child)
	
	var i = 0
	while i < chart_source.chart.events.size():
		var event = chart_source.chart.events[i]
		var event_box = event_box_scene.instantiate()
		var event_name = event.get_script().get_global_name()
		if event_name.substr(0, 5).to_lower() == "event":
			event_name = event_name.substr(5)
		event_box.event_name = event_name
		event_box.time = event.time
		event_box.lane = event.lane
		event_box.id = i
		add_child(event_box)
		i += 1

func _process(_delta):
	update_event_positions()
	get_selection()

func update_event_positions():
	if get_children().size() == 0:
		return
	
	var current_time = song_audio_player.song_progress_seconds
	var scroll_mult = scroll_zoom.value
	var baseline_mult = strum_line_container.timeline_present_point
	baseline_mult = (remap(float(downscroll_toggle.button_pressed), 0, 1, 1, -1) * (baseline_mult - 0.5) + 0.5)
	if downscroll_toggle.button_pressed:
		scroll_mult *= -1.0
	
	if strum_line_container.get_children().size() > 1:
		scroll_mult *= strum_line_container.get_children()[0].size.x / 256.0
	
	var new_min = 0
	for event_box in get_children():
		var lane_offset = -event_lane_width * (event_box.lane)
		var offset = event_box.custom_minimum_size.x - lane_offset
		new_min = max(new_min, offset)
	custom_minimum_size.x = new_min
	
	for event_box in get_children():
		var lane_offset = -event_lane_width * event_box.lane
		event_box.size.x = event_box.custom_minimum_size.x - lane_offset
		event_box.position.x = size.x - event_box.custom_minimum_size.x + lane_offset
		var event_box_y = event_box.time - current_time
		event_box_y *= 64 * scroll_mult
		event_box_y += size.y * baseline_mult
		event_box.position.y = event_box_y - (event_box.size.y * 0.5)
		
		event_box.z_index = max(-event_box.lane, -4096)
