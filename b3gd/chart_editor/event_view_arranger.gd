extends Control

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")

@export var pixel_top: int
@export var extra_right_line_width: int

func _process(_delta):
	update_event_positions()

func update_event_positions():
	var current_time = song_audio_player.song_progress_seconds
	var height = size.y - pixel_top
	var scroll_mult = 1.0 / (%EditorScrollZoom.value * 2.0)
	if %EditorDownscroll.button_pressed:
		scroll_mult *= -1.0
	
	if %StrumlineContainer.get_children().size() > 1:
		scroll_mult *= %StrumlineContainer.get_children()[0].size.x / 256.0
	
	for event_box in get_children():
		var event_box_y = event_box.time - current_time
		event_box_y *= 64 * scroll_mult
		event_box_y += pixel_top
		event_box_y += height * 0.25
		var event_box_grid_width = event_box.custom_minimum_size.x
		var current_event_box_width = event_box_grid_width * (event_box.lane + 1)
		event_box.position.x = size.x - current_event_box_width
		event_box.position.y = event_box_y - (event_box.size.y * 0.5)
		event_box.size.x = current_event_box_width + extra_right_line_width
