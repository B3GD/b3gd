class_name ChartTracks extends Resource

@export var instrumental:AudioStream
# Having both means if one isnt present the other can be used.
@export var mixed_vocals:AudioStream
@export var vocal_layers:Array[AudioStream] # Do in order of strumlines if present
