extends ItemList

@export var song_folder = "res://songs/"
@export var song_scene_name = "song.tscn"

func _ready() -> void:
	for file_name in DirAccess.get_directories_at(song_folder):
		# This doesn't actually use the chart metadata name. 
		# If ur using this to make a real freeplay u gotta change that
		add_item(file_name)


func option_pressed(index: int) -> void:
	get_tree().change_scene_to_file(song_folder + get_item_text(index) + "/" + song_scene_name)
