extends HBoxContainer

@onready var format_box = %EditorTimeFormatBox
@onready var song_audio_player := get_tree().get_first_node_in_group("SongAudioPlayer")

func _process(_delta: float) -> void:
	var time = song_audio_player.song_progress_seconds
	var total = song_audio_player.stream.get_length()
	var has_minutes = true
	if format_box.selected == 1:
		time = song_audio_player.song_progress_beats
		total = song_audio_player.get_beat_from_seconds(total)
		has_minutes = false
	
	$CurrentTimeLabel.text = format_time(time, has_minutes)
	$TotalTimeLabel.text = "/ " + format_time(total, has_minutes)

func format_time(seconds: float, has_minutes: bool) -> String:
	var result = ""
	var seconds_left = seconds
	if seconds < 0:
		seconds_left *= -1
		result += "-"
	if has_minutes:
		result += str(int(seconds_left / 60.0))
		seconds_left -= floor(seconds_left / 60.0) * 60
		result += ":"
	result += str(int(seconds_left)).pad_zeros(2)
	seconds_left -= floor(seconds_left)
	result += "."
	result += str(int(seconds_left * 100)).pad_zeros(2)
	
	return result
