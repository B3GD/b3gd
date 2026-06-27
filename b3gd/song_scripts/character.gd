extends Node

@export var thing_to_animate: Node
@export var miss_sound: AudioStreamPlayer
@export var strumline: int
@export var ignore_sing: bool = false
@export var ignore_miss: bool = false
@export var ignore_idle: bool = false
@export var sing_length = 1.0
@export var idle_anim_order: Array[String] = ["idle"]
@export var note_directions: Array[String] = ["left", "down", "up", "right"]
@export var sing_prefix = "sing_"
@export var miss_prefix = "miss_"
@export var current_suffix: String = ""

var idle_anim_idx = 0
var time_since_last_sing = 0.0

func _ready() -> void:
	var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")
	if song_audio_player == null:
		return
	song_audio_player.beat_hit.connect(beat_hit)
	var note_manager = get_tree().get_first_node_in_group("NoteManager")
	note_manager.note_press.connect(note_press)
	note_manager.note_miss.connect(note_miss)

func _process(delta: float) -> void:
	time_since_last_sing += delta

func beat_hit(_beat: int) -> void:
	if thing_to_animate.is_playing() or time_since_last_sing < sing_length or ignore_idle:
		return
	idle_anim_idx = (idle_anim_idx + 1) % idle_anim_order.size()
	thing_to_animate.play(idle_anim_order[idle_anim_idx] + current_suffix)

func note_press(strum_line_id: int, receptor_id: int, note_data, _hold_delta: float) -> void:
	if strumline != strum_line_id or note_data == null or ignore_sing:
		return
	time_since_last_sing = sing_length if note_data.hold_pressed else 0.0
	thing_to_animate.stop()
	thing_to_animate.play(sing_prefix + note_directions[receptor_id] + current_suffix)

func note_miss(strum_line_id: int, receptor_id: int) -> void:
	if get_tree() == null or strumline != strum_line_id or ignore_miss: 
		return
	miss_sound.play()
	thing_to_animate.play(miss_prefix + note_directions[receptor_id] + current_suffix)
