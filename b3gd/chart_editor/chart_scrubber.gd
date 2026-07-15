extends Node

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")

func _input(event: InputEvent) -> void:
	var step = 8.0 / %EditorSnap.value
	if event.is_action_pressed("editor_time_up"):
		step *= -1
	if %EditorDownscroll.button_pressed:
		step *= -1
	
	if event.is_action_pressed("editor_time_down") or event.is_action_pressed("editor_time_up"):
		var beat = song_audio_player.song_progress_beats
		beat += step
		song_audio_player.track_seek(song_audio_player.get_seconds_from_beat(beat), 0.5)
	if event.is_action_pressed("editor_pause"):
		if song_audio_player.paused: 
			song_audio_player.unpause()
		else:
			song_audio_player.pause()

func _process(delta: float) -> void:
	var new_scrub_position = (song_audio_player.song_progress_seconds / song_audio_player.stream.get_length()) * 100
	if new_scrub_position != %EditorUIScrubber.value:
		%EditorUIScrubber.value_changed.disconnect(_on_editor_ui_scrubber_value_changed)
		%EditorUIScrubber.value = new_scrub_position
		%EditorUIScrubber.value_changed.connect(_on_editor_ui_scrubber_value_changed)

func _on_editor_ui_scrubber_value_changed(value: float) -> void:
	song_audio_player.track_seek(song_audio_player.stream.get_length() * (value / 100.0), 0.5)
