extends Control

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var chart_data_modifier := get_parent().get_parent().get_parent().get_node("%EditorChartDataModifier")


var is_mouse_over = false
var mouse_column: int = -1
var mouse_time: float = 0.0

var creating_note = false
var note_length = 0.0

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var strum_line_id = int(%StrumLineLabel.text)
	match event.button_index:
		1:
			if event.is_pressed() and is_mouse_over:
				creating_note = true
				note_length = 0.0
			if event.is_released() and creating_note:
				creating_note = false
				chart_data_modifier.add_note(strum_line_id, mouse_column, mouse_time, note_length)
		2:
			if !event.is_pressed() or !is_mouse_over:
				return
			chart_data_modifier.remove_note(strum_line_id, mouse_column, mouse_time)

func _process(_delta: float) -> void:
	queue_redraw()
	var mouse_position = get_local_mouse_position()
	is_mouse_over = Rect2(Vector2.ZERO, size).has_point(mouse_position)
	if is_mouse_over:
		var big_parent = get_parent().get_parent().get_parent().get_parent().get_parent()
		var more_global_mouse_position = big_parent.get_local_mouse_position()
		is_mouse_over = Rect2(Vector2.ZERO, big_parent.size).has_point(more_global_mouse_position)
	
	var time_mouse_pos = mouse_position.y - get_parent().transform_y
	var scroll_mult = get_parent().extra_zoom
	if get_parent().downscroll:
		scroll_mult *= -1.0
	time_mouse_pos /= 64 * scroll_mult
	time_mouse_pos += song_audio_player.song_progress_seconds
	time_mouse_pos = chart_data_modifier.get_snapped_time(time_mouse_pos)
	
	if creating_note:
		note_length = max(time_mouse_pos - mouse_time, 0)
	else:
		mouse_time = time_mouse_pos
		mouse_column = floor(mouse_position.x / 64)

func _draw() -> void:
	if !is_mouse_over and !creating_note:
		return
	
	var scroll_mult = get_parent().extra_zoom
	if get_parent().downscroll:
		scroll_mult *= -1.0
	
	var line_y = mouse_time - song_audio_player.song_progress_seconds
	line_y = (line_y * scroll_mult) + (get_parent().transform_y / 64.0) - 0.5
	draw_note(Vector2(mouse_column, line_y), Vector2i(mouse_column, 1))
	
	if !creating_note:
		return
	
	var line_end = (mouse_time + note_length) - song_audio_player.song_progress_seconds
	line_end *= scroll_mult
	line_end += (get_parent().transform_y / 64.0)
	line_end -= 0.5
	draw_note(
		Vector2(mouse_column, line_y + 0.5),
		Vector2i(mouse_column, 2),
		line_end - line_y
	)

func draw_note(pos: Vector2, idx: Vector2i, height: float = 1.0):
	if height < 0:
		draw_texture_rect_region(
			get_parent().notes_texture,
			Rect2(Vector2(pos.x, pos.y + height) * 64, Vector2(1, height) * 64),
			Rect2(idx * 64, Vector2.ONE * 64),
			Color(Color.WHITE, 0.3)
		)
	else:
		draw_texture_rect_region(
			get_parent().notes_texture,
			Rect2(pos * 64, Vector2(1, height) * 64),
			Rect2(idx * 64, Vector2.ONE * 64),
			Color(Color.WHITE, 0.3)
		)
