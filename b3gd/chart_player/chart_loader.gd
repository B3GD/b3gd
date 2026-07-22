extends Node

signal tracks_loaded()
signal notes_loaded()
signal events_loaded()

@export_group("Node References")
@export var chart_source:Node
@export var song_audio_player:AudioStreamPlayer
@export var note_manager:Node
@export var event_player:Node

func _ready() -> void:
	load_chart()

func load_chart():
	load_tracks()
	load_notes(false)
	load_events()

var vocal_layers = []

func load_tracks():
	var chart = chart_source.chart
	var tracks: Array[AudioStream] = [
		chart.tracks.instrumental, 
		chart.tracks.mixed_vocals
	]
	var start_index = tracks.size() - 1
	tracks.append_array(chart.tracks.vocal_layers)
	vocal_layers = []
	for i in chart.tracks.vocal_layers.size():
		vocal_layers.append(i + start_index)
	
	for track in tracks:
		if track == null:
			tracks.erase(track)
	
	var audio_stream = AudioStreamSynchronized.new()
	audio_stream.stream_count = tracks.size()
	for i in range(tracks.size()):
		audio_stream.set_sync_stream(i, tracks[i])
	song_audio_player.stream = audio_stream
	tracks_loaded.emit()

func load_notes(ignore_past_notes: bool = false):
	note_manager.strum_lines = chart_source.chart.strum_lines.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	
	for strum_line in note_manager.strum_lines:
		strum_line.function = [note_manager.player_receptor_input, note_manager.cpu_receptor_input][int(strum_line.cpu)]
		for receptor in strum_line.receptors:
			receptor.last_press = Receptor.ReceptorInput.new()
			receptor.last_press.input_time = 0
			receptor.last_press.ignore_draw = true
			receptor.last_press.dummy = true
	
	if ignore_past_notes:
		remove_notes_from_past()
	
	notes_loaded.emit()

func remove_notes_from_past():
	for strum_line in note_manager.strum_lines:
		for receptor in strum_line.receptors:
			var future_id_found = false
			var note_id = 0
			while note_id < receptor.notes.size() and !future_id_found:
				if receptor.notes[note_id].time >= song_audio_player.song_progress_seconds:
					future_id_found = true
					continue
				note_id += 1
			receptor.notes = receptor.notes.slice(note_id)

func load_events():
	event_player.events = chart_source.chart.events
	event_player.init_events()
	events_loaded.emit()
