extends HBoxContainer

@onready var format_box = %EditorTimeFormatBox
@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

func _process(_delta: float) -> void:
	var time = song_audio_player.song_progress_seconds
	var total = song_audio_player.stream.get_length()
	$CurrentTimeLabel.text = format_time_into_minutes(time)
	$TotalTimeLabel.text = format_time_into_minutes(total)

func format_time_into_minutes(seconds: float) -> String:
	var result = ""
	var seconds_left = seconds
	if seconds < 0:
		seconds_left *= -1
		result += "-"
	
	result += str(int(seconds_left / 60.0))
	result += ":"
	result += str(int(seconds_left)).pad_zeros(2)
	seconds_left -= floor(seconds_left)
	result += "."
	result += str(int(seconds_left * 100)).pad_zeros(2)
	
	return result
