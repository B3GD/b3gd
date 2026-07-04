extends Node
# I also stole this whole script from myself, it might need adjustment - gitgato

var force_inactive := false # Chart editor will temporarily disable input.

signal note_press(strum_line_id: int, receptor_id: int, note: Note, hold_delta: float)
signal note_miss(strum_line_id: int, receptor_id: int)

@export var hit_window = 0.2
@export var hold_end_window = 0.12
@export_group("Node References")
@export var chart_loader: Node
@export var song_audio_player: AudioStreamPlayer

var strum_lines: Array[StrumLine] = []

func _process(_delta: float) -> void:
	if force_inactive:
		return
	for strum_line_id in range(strum_lines.size()):
		for receptor_id in strum_lines[strum_line_id].receptors.size():
			if strum_lines[strum_line_id].cpu:
				handle_auto_receptor_input(strum_line_id, receptor_id)
			else:
				handle_manual_receptor_input(strum_line_id, receptor_id)

func handle_auto_receptor_input(strum_line_id, receptor_id):
	if strum_lines[strum_line_id].receptors[receptor_id].notes.size() == 0:
		return
	while strum_lines[strum_line_id].receptors[receptor_id].notes[0].time <= song_audio_player.song_progress_seconds:
		hit_note(strum_line_id, receptor_id)
		if strum_lines[strum_line_id].receptors[receptor_id].notes.size() == 0:
			return

func handle_manual_receptor_input(strum_line_id, receptor_id):
	var input_name = "strumline_" + str(receptor_id)
	if !InputMap.has_action(input_name):
		return
	var is_pressed = Input.is_action_just_pressed(input_name)
	var is_held = Input.is_action_pressed(input_name)
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	receptor.last_press.ignore_draw = !is_held
	
	var note_distance = 100000
	if receptor.notes.size() > 0:
		note_distance = receptor.notes[0].time - song_audio_player.song_progress_seconds
	
	# If note outside of range, only ghost tap.
	if note_distance > hit_window * 0.5:
		if is_pressed:
			hit_dummy(strum_line_id, receptor_id)
		return
	
	# If theres no notes here, nothing will happen.
	if receptor.notes.size() == 0:
		return
	
	# If hold is almost done but end is forgotten, delete.
	if !is_held and receptor.notes[0].hold_pressed and receptor.notes[0].length < hold_end_window:
		receptor.notes.pop_front()
	
	# If a note is behind hit window, Miss it
	if note_distance <= -hit_window * 0.5:
		miss_note(strum_line_id, receptor_id)
		return
	
	if is_pressed or (is_held and receptor.notes[0].hold_pressed):
		hit_note(strum_line_id, receptor_id)

func hit_dummy(strum_line_id, receptor_id):
	strum_lines[strum_line_id].receptors[receptor_id].last_press.input_time = song_audio_player.song_progress_seconds
	strum_lines[strum_line_id].receptors[receptor_id].last_press.dummy = true
	note_press.emit(strum_line_id, receptor_id, null, 1.0)

func hit_note(strum_line_id, receptor_id):
	mute_strumline(strum_line_id, false)
	
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	receptor.last_press.input_time = song_audio_player.song_progress_seconds
	receptor.last_press.dummy = false
	var note_ref = receptor.notes[0]
	
	if note_ref.length > 0:
		var time_difference = song_audio_player.song_progress_seconds - note_ref.time
		move_sustain(strum_line_id, receptor_id, time_difference)
		note_ref.hold_pressed = true
		if note_ref.note_hit():
			note_press.emit(strum_line_id, receptor_id, note_ref, time_difference)
	
	if note_ref.length <= 0:
		var sushit = note_ref.hold_pressed
		var note_dupe = note_ref.duplicate()
		receptor.notes.pop_front()
		if !sushit:
			if note_ref.note_hit():
				note_press.emit(strum_line_id, receptor_id, note_dupe, 1.0)

func miss_note(strum_line_id, receptor_id):
	mute_strumline(strum_line_id, true)
	
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	var note_ref = receptor.notes[0]
	
	if note_ref.note_miss():
		note_miss.emit(strum_line_id, receptor_id)
	
	if note_ref.length > 0:
		move_sustain(strum_line_id, receptor_id, hit_window)
		note_ref.hold_pressed = true
		if note_ref.length > 0:
			return
	receptor.notes.pop_front()

func move_sustain(strum_line_id, receptor_id, by: float):
	var note = strum_lines[strum_line_id].receptors[receptor_id].notes[0]
	note.time += by
	note.length -= by

func mute_strumline(strum_line_id, mute):
	var vocal_layer = chart_loader.vocal_layers[strum_line_id]
	prints(vocal_layer, song_audio_player.stream.get_sync_stream_volume(vocal_layer))
	song_audio_player.stream.set_sync_stream_volume(vocal_layer, -50 if mute else 0)
