extends Control

@export var notes_texture: Texture2D
@export var strum_line_idx: int = 1

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var chart_source := get_tree().get_first_node_in_group("ChartSource")

@onready var scroll_zoom = get_parent().get_parent().get_node("%EditorScrollZoom")
@onready var downscroll_toggle = get_parent().get_parent().get_node("%EditorDownscroll")

var downscroll = false
var extra_zoom = 1.0
var transform_y = size.y + position.y


func _process(_delta: float) -> void:
	var timeline_present_point = get_parent().get_parent().timeline_present_point
	
	transform_y = size.y + position.y
	transform_y *= (remap(float(downscroll), 0, 1, 1, -1) * (timeline_present_point - 0.5) + 0.5)
	transform_y -= position.y
	
	extra_zoom = 1.0
	if scroll_zoom != null:
		extra_zoom /= scroll_zoom.value * 2.0
	if downscroll_toggle != null:
		downscroll = downscroll_toggle.button_pressed
	
	queue_redraw()

func _draw() -> void:
	custom_minimum_size.x = (64 * note_manager.strum_lines[strum_line_idx].receptors.size())
	#var fill_scale = size.x / custom_minimum_size.x
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.25))
	draw_set_transform(
		Vector2(0, transform_y), 
		0.0, 
		Vector2.ONE
	)
	draw_receptors()

func draw_receptors():
	var current_time = song_audio_player.song_progress_seconds
	var scroll_mult = extra_zoom
	if downscroll:
		scroll_mult *= -1.0
	
	var current_beat = song_audio_player.song_progress_beats
	
	var grid_range = 128
	@warning_ignore("integer_division") # I want these to round. so if you give a weird range its ok
	var grid_start_time = round(current_beat) - (grid_range / 2)
	@warning_ignore("integer_division") # I want these to round. so if you give a weird range its ok
	var grid_end_time = round(current_beat) + (grid_range / 2)
	var current_grid_time = grid_start_time
	while current_grid_time < grid_end_time:
		var line_y = song_audio_player.get_seconds_from_beat(current_grid_time) - current_time
		line_y *= scroll_mult * 64
		
		var mod_version = fmod(current_grid_time + 1000.0, 2.0)
		var alpha = lerp(0.5, 0.25, mod_version)
		
		draw_line(
			Vector2(0, line_y),
			Vector2(custom_minimum_size.x, line_y),
			Color(1.0, 1.0, 1.0, alpha)
		)
		current_grid_time += 1
	
	for receptor_id in range(note_manager.strum_lines[strum_line_idx].receptors.size()):
		draw_note(Vector2(receptor_id, -0.5), Vector2i(receptor_id, 0))
		for note in note_manager.strum_lines[strum_line_idx].receptors[receptor_id].notes:
			var note_y = (note.time - current_time) * scroll_mult
			draw_note(Vector2(receptor_id, note_y - 0.5), Vector2i(receptor_id, 1))
			if is_zero_approx(note.length):
				continue
			var note_length = note.length * scroll_mult
			if note_length > 0:
				draw_note(Vector2(receptor_id, note_y), Vector2i(receptor_id, 2), note_length)
			else:
				draw_note(Vector2(receptor_id, note_y + note_length), Vector2i(receptor_id, 2), abs(note_length))

func draw_note(pos: Vector2, idx: Vector2i, height: float = 1.0):
	draw_texture_rect_region(
		notes_texture,
		Rect2(pos.x * 64, pos.y * 64, 64, height * 64),
		Rect2(idx.x * 64, idx.y * 64, 64, 64),
	)
