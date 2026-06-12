extends Node

signal pre_init_events()

var last_played_event: int = -1
var events:Array[Event]

@export_group("Node References")
@export var song_audio_player: Node

func _process(delta: float) -> void:
	process_events()

func init_events() -> void:
	pre_init_events.emit()
	for event in events:
		event.parent = self
		event.init()

func process_events() -> void:
	var next_event = null
	if last_played_event != -1 and events[last_played_event].time > song_audio_player.song_progress_seconds:
		last_played_event = max(last_played_event - 1, 0)
		events[last_played_event].play(song_audio_player.pitch_scale * -1)
		return
	if last_played_event >= events.size() - 1:
		return
	if events[last_played_event + 1].time <= song_audio_player.song_progress_seconds:
		last_played_event += 1
		events[last_played_event].play(song_audio_player.pitch_scale * 1)
