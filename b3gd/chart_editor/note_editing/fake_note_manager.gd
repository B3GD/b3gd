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
			while handle_note(strum_line_id, receptor_id):
				continue

func handle_note(strum_line_id, receptor_id) -> bool:
	var receptor = note_manager.strum_lines[strum_line_id].receptors[receptor_id]
	if receptor.notes.size() == 0:
		return false
	
	var current_note_id = hit_note_ids[strum_line_id][receptor_id]
	if current_note_id >= receptor.notes.size():
		return false
	
	if current_note_id >= 0 and !receptor.notes[current_note_id].time <= song_audio_player.song_progress_seconds:
		hit_note_ids[strum_line_id][receptor_id] -= 1
		return false
	
	if receptor.notes.size() <= current_note_id + 1:
		return false
	
	var next_note = receptor.notes[current_note_id + 1]
	
	if next_note.time <= song_audio_player.song_progress_seconds:
		hit_note_ids[strum_line_id][receptor_id] = current_note_id + 1
		note_manager.note_press.emit(strum_line_id, receptor_id, next_note, 0.0)
		if %EditorHitSound.button_pressed and frames_born > 5:
			$NoteClick.play()
		return true
	return false
