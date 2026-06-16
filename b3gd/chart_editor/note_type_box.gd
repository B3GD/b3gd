extends OptionButton

var note_class = []

func _ready() -> void:
	print(ProjectSettings.get_global_class_list().size())
	for global_class in ProjectSettings.get_global_class_list():
		if load(global_class.path).new() is Note:
			add_item(global_class.class)
			note_class.append(global_class.path)
