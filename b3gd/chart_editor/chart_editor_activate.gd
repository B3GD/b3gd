extends Node

@export var chart: Chart

func _ready() -> void:
	override_with_editor()

func override_with_editor() -> void:
	$NoteManager.force_inactive = true


func _on_chart_info_button_pressed() -> void:
	pass # Replace with function body.
