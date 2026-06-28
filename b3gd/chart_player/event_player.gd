extends Node

signal pre_init_events()

var last_played_event: int = -1
var events:Array[Event]

@export_group("Node References")
@export var song_audio_player: Node

func _process(_delta: float) -> void:
	var i = 0
	while process_events():
		i += 1
		if i > 8000:
			printerr(">8000 Events just tried to play in one frame. What")
			return

func init_events() -> void:
	pre_init_events.emit()
	for event in events:
		event.parent = self
		event.init()

func process_events() -> bool:
	if last_played_event != -1 and events[last_played_event].time > song_audio_player.song_progress_seconds:
		last_played_event = max(last_played_event - 1, -1)
		events[last_played_event].play(song_audio_player.pitch_scale * -1)
		return true
	if last_played_event >= events.size() - 1:
		return false
	if events[last_played_event + 1].time <= song_audio_player.song_progress_seconds:
		last_played_event += 1
		events[last_played_event].play(song_audio_player.pitch_scale * 1)
		return true
	return false
