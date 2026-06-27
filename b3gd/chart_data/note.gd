class_name Note extends Resource

# Needed for chart data
## The time the note occurs in seconds.
@export var time: float
## The length of the note, if zero this is not a hold note. 
@export_range(0.0, 1.0, 0.0, "or_greater") var length:float = 0
# Needed for runtime data
## Used to check if the hold has begun. Used for rendering and input.
## I'm fine with this being in chart data as it is a single bool
var hold_pressed = false
