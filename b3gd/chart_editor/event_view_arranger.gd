extends Control

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")

@export var event_box_scene: PackedScene
@export var pixel_top: int
@export var extra_right_line_width: int

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var scroll_zoom = %EditorScrollZoom
@onready var downscroll_toggle = %EditorDownscroll
@onready var strum_line_container = %StrumLineContainer

func _ready() -> void:
	update_events()

func update_events():
	for child in get_children():
		remove_child(child)
	
	var i = 0
	while i < chart_source.chart.events.size():
		var event = chart_source.chart.events[i]
		var event_box = event_box_scene.instantiate()
		event_box.event_name = event.get_script().get_global_name()
		event_box.time = event.time
		event_box.lane = event.lane
		event_box.id = i
		add_child(event_box)
		i += 1

func _process(_delta):
	update_event_positions()

func update_event_positions():
	if get_children().size() == 0:
		return
	
	var current_time = song_audio_player.song_progress_seconds
	var height = size.y - pixel_top
	var scroll_mult = 1.0 / (scroll_zoom.value * 2.0)
	var baseline_mult = 0.25
	if downscroll_toggle.button_pressed:
		baseline_mult = 0.75
		scroll_mult *= -1.0
	
	if strum_line_container.get_children().size() > 1:
		scroll_mult *= strum_line_container.get_children()[0].size.x / 256.0
	
	for event_box in get_children():
		var event_box_y = event_box.time - current_time
		event_box_y *= 64 * scroll_mult
		event_box_y += pixel_top
		event_box_y += height * baseline_mult
		var event_box_grid_width = event_box.custom_minimum_size.x
		var current_event_box_width = event_box_grid_width * (event_box.lane + 1)
		event_box.position.x = size.x - current_event_box_width
		event_box.position.y = event_box_y - (event_box.size.y * 0.5)
		event_box.size.x = current_event_box_width + extra_right_line_width
