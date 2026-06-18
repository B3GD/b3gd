extends SpinBox

@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")


func _on_value_changed(value: float) -> void:
	song_audio_player.pitch_scale = value
