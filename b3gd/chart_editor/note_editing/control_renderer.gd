extends Control

@export var notes_texture: Texture2D
@export var strum_line_idx: int = 1

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var chart_source := get_tree().get_first_node_in_group("ChartSource")
@onready var scroll_zoom = get_parent().get_parent().get_node("%EditorScrollZoom")
@onready var downscroll_toggle = get_parent().get_parent().get_node("%EditorDownscroll")
@onready var snap = get_parent().get_parent().get_node("%EditorSnap")

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
		extra_zoom *= scroll_zoom.value
	if downscroll_toggle != null:
		downscroll = downscroll_toggle.button_pressed
	
	queue_redraw()

func _draw() -> void:
	custom_minimum_size.x = 64 * note_manager.strum_lines[strum_line_idx].receptors.size()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.25))
	draw_set_transform(Vector2(0, transform_y), 0.0, Vector2.ONE)
	draw_receptors()

func draw_receptors():
	var current_time = song_audio_player.song_progress_seconds
	var scroll_mult = extra_zoom
	if downscroll:
		scroll_mult *= -1.0
	
	var grid_range = 128
	var current_beat_rounded = round(song_audio_player.song_progress_beats)
	@warning_ignore("integer_division") # I want these to round. its ok
	var grid_range_center = grid_range / 2
	var grid_end_time = current_beat_rounded + grid_range_center
	var grid_start_time = current_beat_rounded - grid_range_center
	var current_grid_time = grid_start_time
	while current_grid_time < grid_end_time:
		var line_y = song_audio_player.get_seconds_from_beat(current_grid_time) - current_time
		line_y *= scroll_mult * 64
		
		var alpha = 1.0
		var round_time_for_highlight = snapped(current_grid_time, 0.0001)
		if round(round_time_for_highlight * 8.0) == round_time_for_highlight * 8.0:
			alpha = [
				0.0, 0.95, 0.8, 0.95, 0.5, 0.95, 0.8, 0.95
			][int(floor(round_time_for_highlight * 8) - (floor(round_time_for_highlight) * 8))]
		
		alpha = lerp(0.75, 0.125, alpha)
		
		var min_distance = min(
			current_grid_time - grid_start_time,
			grid_end_time - current_grid_time
		)
		alpha *= min(min_distance * 0.03 , 1.0)
		
		draw_line(
			Vector2(0, line_y),
			Vector2(custom_minimum_size.x, line_y),
			Color(Color.WHITE, alpha)
		)
		current_grid_time += 1.0 / float(snap.value)
	
	var song_start = 0.0 - current_time
	song_start *= scroll_mult * 64
	var song_end = song_audio_player.stream.get_length() - current_time
	song_end *= scroll_mult * 64
	if downscroll:
		var song_start_dupe = song_start
		song_start = song_end
		song_end = song_start_dupe
	
	draw_rect(
		Rect2(0, floor(-transform_y), size.x, floor(song_start + transform_y)),
		Color(Color.BLACK, 0.2)
	)
	
	draw_rect(
		Rect2(0, floor(song_end), size.x, size.y),
		Color(Color.BLACK, 0.2)
	)
	
	for receptor_id in range(note_manager.strum_lines[strum_line_idx].receptors.size()):
		draw_note(Vector2(receptor_id, -0.5), Vector2i(receptor_id, 0))
		
		for note in note_manager.strum_lines[strum_line_idx].receptors[receptor_id].notes:
			var note_y = (note.time - current_time) * scroll_mult
			var note_length = note.length * scroll_mult
			
			if ((note_y + 0.5) * 64) + note_length < -transform_y:
				if downscroll:
					break
				else:
					continue
			if (note_y * 64) > size.y:
				if downscroll:
					continue
				else:
					break
			
			draw_note(Vector2(receptor_id, note_y - 0.5), Vector2i(receptor_id, 1))
			
			if is_zero_approx(note_length):
				continue
			
			if note_length > 0:
				draw_note(Vector2(receptor_id, note_y), Vector2i(receptor_id, 2), note_length)
			else:
				draw_note(Vector2(receptor_id, note_y + note_length), Vector2i(receptor_id, 2), abs(note_length))

func draw_note(pos: Vector2, idx: Vector2i, height: float = 1.0):
	draw_texture_rect_region(
		notes_texture,
		Rect2(pos * 64, Vector2(1, height) * 64),
		Rect2(idx * 64, Vector2.ONE * 64),
	)
