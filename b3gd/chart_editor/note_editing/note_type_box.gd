extends OptionButton

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		if load(global_class.path).new() is Note:
			add_item(global_class.class)
			class_paths.append(global_class.path)
