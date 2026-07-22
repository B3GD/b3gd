extends Node

signal note_press(strum_line_id: int, receptor_id: int, note: Note, hold_delta: float)
signal note_miss(strum_line_id: int, receptor_id: int, note: Note)

## Hit window in seconds. Spans both sides. 
## (e.g. a hit window of 0.2 means 0.1 seconds before and after.)
@export var hit_window = 0.2
@export var hold_end_window = 0.12
@export_group("Node References")
@export var chart_loader: Node
@export var song_audio_player: AudioStreamPlayer

var strum_lines: Array[StrumLine] = []

func _process(_delta: float) -> void:
	for strum_line_id in range(strum_lines.size()):
		for receptor_id in strum_lines[strum_line_id].receptors.size():
			strum_lines[strum_line_id].function.call(strum_line_id, receptor_id)

func cpu_receptor_input(strum_line_id, receptor_id):
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	
	if receptor.notes.size() == 0:
		return
	
	while receptor.notes[0].time <= song_audio_player.song_progress_seconds:
		hit_note(strum_line_id, receptor_id)
		receptor.last_press.ignore_draw = false
		if receptor.notes.size() == 0 or receptor.notes[0].hold_pressed:
			return

func player_receptor_input(strum_line_id, receptor_id):
	var input_name = "strumline_" + str(receptor_id)
	assert(InputMap.has_action(input_name), "Action " + input_name + " does not exist.")
	var is_pressed = Input.is_action_just_pressed(input_name)
	var is_held = Input.is_action_pressed(input_name)
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	receptor.last_press.ignore_draw = !is_held
	
	var note_distance = 100000
	if receptor.notes.size() > 0:
		note_distance = receptor.notes[0].time - song_audio_player.song_progress_seconds
	
	if note_distance > hit_window * 0.5:
		if is_pressed:
			hit_dummy(strum_line_id, receptor_id)
	elif note_distance < hit_window * -0.5:
		miss_note(strum_line_id, receptor_id)
	else:
		if !is_held and receptor.notes[0].hold_pressed and receptor.notes[0].length < hold_end_window:
			receptor.notes.pop_front()
		
		if is_pressed or (is_held and receptor.notes[0].hold_pressed):
			hit_note(strum_line_id, receptor_id)

func hit_dummy(strum_line_id, receptor_id):
	strum_lines[strum_line_id].receptors[receptor_id].last_press.input_time = song_audio_player.song_progress_seconds
	strum_lines[strum_line_id].receptors[receptor_id].last_press.dummy = true
	note_press.emit(strum_line_id, receptor_id, null, 1.0)

func hit_note(strum_line_id, receptor_id):
	var receptor = strum_lines[strum_line_id].receptors[receptor_id]
	receptor.last_press.input_time = song_audio_player.song_progress_seconds
	receptor.last_press.dummy = false
	var note = receptor.notes[0]
	
	var time_difference = song_audio_player.song_progress_seconds - note.time
	
	if note.note_hit():
		note_press.emit(strum_line_id, receptor_id, note, time_difference)
		mute_strumline(strum_line_id, false)
	
	if note.length > 0:
		move_sustain(strum_line_id, receptor_id, time_difference)
	else:
		receptor.notes.pop_front()

func miss_note(strum_line_id, receptor_id):
	var note = strum_lines[strum_line_id].receptors[receptor_id].notes[0]
	
	if note.note_miss():
		note_miss.emit(strum_line_id, receptor_id, note)
		mute_strumline(strum_line_id, true)
	
	if note.length > 0:
		move_sustain(strum_line_id, receptor_id, hit_window, true)
	else:
		strum_lines[strum_line_id].receptors[receptor_id].notes.pop_front()

func move_sustain(strum_line_id, receptor_id, by: float, miss_on_negative: bool = false):
	var note = strum_lines[strum_line_id].receptors[receptor_id].notes[0]
	note.time += by
	note.length -= by
	note.hold_pressed = true
	if note.length < 0 and miss_on_negative:
		miss_note(strum_line_id, receptor_id)

func mute_strumline(strum_line_id, mute):
	var vocal_layer = chart_loader.vocal_layers[strum_line_id]
	song_audio_player.stream.set_sync_stream_volume(vocal_layer, -50 if mute else 0)
