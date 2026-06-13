extends Control

@export var notes_texture: Texture2D
@export var strum_line_idx: int = 1
@export var scroll_zoom: float = 1

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager := get_tree().get_first_node_in_group("NoteManager")
@onready var chart_source := get_tree().get_first_node_in_group("ChartSource")

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var fill_scale = size.x / 256
	draw_set_transform(
		Vector2(0, size.y * (0.25 + (float(%EditorDownscroll.button_pressed) * 0.5))), 
		0.0,
		Vector2(fill_scale, fill_scale)
	)
	draw_receptors()

func draw_receptors():
	var current_time = song_audio_player.song_progress_seconds
	var scroll_mult = 1.0
	if %EditorDownscroll.button_pressed:
		scroll_mult *= -1.0
	
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
