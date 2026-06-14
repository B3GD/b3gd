extends Control

var id = 0
var time = 0
var event_name = "":
	set(value):
		event_name = value
		$Button.text = event_name
var lane = 0

@onready var button = $Button
@onready var arrow = $Arrow
