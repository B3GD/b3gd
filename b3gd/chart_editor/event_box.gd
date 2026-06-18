extends Control

var id = 0
var time = 0
var event_name = "":
	set(value):
		event_name = value
		var old_size = $Button.size.x
		$Button.text = event_name
		await $Button.draw
		var size_offset = $Button.size.x - old_size
		$Button.position.x -= size_offset
var lane = 0

@onready var button = $Button
@onready var arrow = $Arrow
