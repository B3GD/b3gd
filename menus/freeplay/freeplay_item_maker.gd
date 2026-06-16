extends ItemList

@export var song_folder = "res://songs/"
@export var song_scene_name = "song.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for file_name in DirAccess.get_directories_at(song_folder):
		add_item(file_name)


func option_pressed(index: int) -> void:
	get_tree().change_scene_to_file(song_folder + get_item_text(index) + "/" + song_scene_name)
