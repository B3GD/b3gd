class_name NoteskinGridData extends Resource

@export var grid_size: Vector2i = Vector2i(64, 64)
@export_enum("horizontal", "vertical") var orientation: int = 1
@export var hold_part_height = 32
@export_group("Frame Data")
@export var idle_animation_fps = 4
@export var active_animation_fps = 24
@export_group("Idle Animation Data")
@export var receptor_frames: Array[int] = [0]
@export var note_frames: Array[int] = [5]
@export var hold_frames: Array[int] = [6]
@export var hold_end_frames: Array[int] = [7]
@export_group("Active Animation Data")
@export var receptor_dummy_frames: Array[int] = [3, 3, 4]
@export var receptor_hit_frames: Array[int] = [1, 2, 2, 0]
