extends HBoxContainer

@onready var format_box = %EditorTimeFormatBox
@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

func _process(_delta: float) -> void:
	var time = song_audio_player.song_progress_seconds
	var total = song_audio_player.stream.get_length()
	print(time, total)

func return_time_seconds():
	pass
