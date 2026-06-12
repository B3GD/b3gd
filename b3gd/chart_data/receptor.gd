class_name Receptor extends Resource

@export var notes: Array[Note]

class ReceptorInput extends RefCounted:
	## The time the input occured. Used for rendering
	@export var input_time: float
	## If drawing this press should be ignored. For when an input is released
	@export var ignore_draw: bool
	## This is "true" when the input didnt hit any notes.
	@export var dummy: bool

var last_press:ReceptorInput
