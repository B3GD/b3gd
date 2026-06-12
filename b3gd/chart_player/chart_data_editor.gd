extends Node

@export_group("Node References")
@export var chart_source:Node
@export var chart_loader:Node
@export var song_audio_player:AudioStreamPlayer
@export var note_manager:Node
@export var event_player:Node

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	for i in range(4):
		var input_name = "strumline_" + str(i)
		if !InputMap.has_action(input_name):
			return
		if event.is_action_pressed(input_name):
			add_note(1, i, song_audio_player.song_progress_seconds, 0.0)

func add_note(strum_line, receptor, time, length):
	var new_note = Note.new()
	new_note.time = time
	new_note.length = length
	chart_source.chart.strum_lines[strum_line].receptors[receptor].notes.append(new_note)
	chart_source.chart.strum_lines[strum_line].receptors[receptor].notes.sort_custom(sort_ascending)
	chart_loader.load_notes()

func sort_ascending(a, b):
	return a.time < b.time
