extends Node

@export var chart: Chart
var editor_path = "res://b3gd/chart_editor/chart_editor.tscn"
var editor = null

func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"):
		return
	
	if event.is_action_pressed("editor_activate"):
		if editor == null:
			add_editor()
		else:
			erase_editor()

func erase_editor() -> void:
	editor.queue_free()
	editor = null
	$ChartLoader.load_notes(true)
	$NoteManager.force_inactive = false
	$UI.visible = true
	
	if $SongAudioPlayer.paused: 
		$SongAudioPlayer.unpause()

func add_editor() -> void:
	$NoteManager.force_inactive = true
	$ChartLoader.load_chart()
	editor = load(editor_path).instantiate()
	add_child(editor)
	$UI.visible = false
