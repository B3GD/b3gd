class_name Chart extends Resource

const abstract = false

@export var metadata:ChartMetadata
@export var tracks:ChartTracks
@export var strum_lines:Array[StrumLine]
@export var events:Array[Event]

@export_range(0.0, 8.0, 0.1, "or_greater") var scroll_speed: float
