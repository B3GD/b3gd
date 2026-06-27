extends Node

@onready var song_audio_player = get_tree().get_first_node_in_group("SongAudioPlayer")
@onready var note_manager = get_tree().get_first_node_in_group("NoteManager")

var hit_note_ids = []
var frames_born = 0

func _ready() -> void:
	init_hit_notes()

func init_hit_notes():
	hit_note_ids = []
	# This can probably be optimized more, lol
	for strum_line_id in range(note_manager.strum_lines.size()):
		hit_note_ids.append([])
		for receptor_id in note_manager.strum_lines[strum_line_id].receptors.size():
			hit_note_ids[-1].append(-1)
			for note_id in note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes.size():
				var note_to_hit = note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes[note_id]
				if note_to_hit.time <= song_audio_player.song_progress_seconds:
					hit_note_ids[-1][-1] = note_id

func _process(_delta: float) -> void:
	frames_born += 1
	for strum_line_id in range(note_manager.strum_lines.size()):
		for receptor_id in note_manager.strum_lines[strum_line_id].receptors.size():
			for note_id in note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes.size():
				handle_note(strum_line_id, receptor_id, note_id)

func handle_note(strum_line_id, receptor_id, note_id):
	var note_to_hit = note_manager.strum_lines[strum_line_id].receptors[receptor_id].notes[note_id]
	
	var note_passed = note_to_hit.time <= song_audio_player.song_progress_seconds
	var note_already_hit = hit_note_ids[strum_line_id][receptor_id] >= note_id
	if note_passed and !note_already_hit:
		hit_note_ids[strum_line_id][receptor_id] = note_id
		note_manager.note_press.emit(strum_line_id, receptor_id, note_to_hit, 0.0)
		if %EditorHitSound.button_pressed and frames_born > 5:
			$NoteClick.play()
	
	if !note_passed and note_already_hit:
		hit_note_ids[strum_line_id][receptor_id] = note_id - 1
