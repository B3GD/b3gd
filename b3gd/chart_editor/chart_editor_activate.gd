extends Node

@export var chart: Chart

func _ready() -> void:
	override_with_editor()

func override_with_editor() -> void:
	$NoteManager.force_inactive = true
