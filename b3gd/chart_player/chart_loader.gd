extends Node

@export_group("Node References")
@export var chart_source:Node
@export var song_audio_player:AudioStreamPlayer
@export var note_manager:Node
@export var event_player:Node
@export var status_handler:Node

func _ready() -> void:
	load_chart()

func load_chart():
	chart_variable_init()
	load_tracks()
	load_notes()
	load_events()

func chart_variable_init():
	for strum_line in chart_source.chart.strum_lines:
		for receptor in strum_line.receptors:
			receptor.last_press = Receptor.ReceptorInput.new()
			receptor.last_press.input_time = 0
			receptor.last_press.ignore_draw = true
			receptor.last_press.dummy = true

func load_tracks():
	var chart = chart_source.chart
	
	var tracks: Array[AudioStream] = [
		chart.tracks.instrumental, 
		chart.tracks.mixed_vocals
	]
	tracks.append_array(chart.tracks.vocal_layers)
	
	for track in tracks:
		if track == null:
			tracks.erase(track)
	
	var audio_stream = AudioStreamSynchronized.new()
	audio_stream.stream_count = tracks.size()
	for i in range(tracks.size()):
		audio_stream.set_sync_stream(i, tracks[i])
	song_audio_player.stream = audio_stream

func load_notes(ignore_past_notes: bool = false):
	note_manager.strum_lines = chart_source.chart.strum_lines
	
	if !ignore_past_notes:
		return
	
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
