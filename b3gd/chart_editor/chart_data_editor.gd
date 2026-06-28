extends Node

@export_group("Node References")
@onready var chart_source:Node = get_tree().get_first_node_in_group("ChartSource")
@onready var chart_loader:Node = get_tree().get_first_node_in_group("ChartLoader")
@onready var song_audio_player:AudioStreamPlayer = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager:Node = get_tree().get_first_node_in_group("NoteManager")
@onready var event_player:Node = get_tree().get_first_node_in_group("EventPlayer")

func _ready() -> void:
	chart_loader.events_loaded.connect(events_loaded)

func get_snapped_time(seconds: float):
	var beat = song_audio_player.get_beat_from_seconds(seconds)
	beat = snappedf(beat, 1.0 / %EditorSnap.value)
	return song_audio_player.get_seconds_from_beat(beat)

func add_note(strum_line, receptor, time, length):
	var new_note = load(%EditorNoteClassBox.class_paths[%EditorNoteClassBox.selected]).new()
	new_note.time = time
	new_note.length = length
	chart_source.chart.strum_lines[strum_line].receptors[receptor].notes.append(new_note)
	chart_source.chart.strum_lines[strum_line].receptors[receptor].notes.sort_custom(sort_ascending)
	chart_loader.load_notes(false)

func add_event(time):
	var new_event = load(%EditorEventClassBox.class_paths[%EditorEventClassBox.selected]).new()
	new_event.time = time
	var max_lane_at_pos = -1
	for event in chart_source.chart.events:
		if abs(event.time - time) < 0.05:
			max_lane_at_pos = max(max_lane_at_pos, event.lane)
	new_event.lane = max_lane_at_pos + 1
	
	chart_source.chart.events.append(new_event)
	chart_source.chart.events.sort_custom(sort_ascending)
	chart_loader.load_events()

func events_loaded():
	%EditorEventContainer.update_events()

func remove_note(strum_line, receptor, time):
	var notes = chart_source.chart.strum_lines[strum_line].receptors[receptor].notes
	for note in notes:
		if abs(note.time - time) < 0.05:
			notes.remove_at(notes.find(note)) # Only removes one at a time
			break
	chart_loader.load_notes(false)

func sort_ascending(a, b):
	return a.time < b.time
