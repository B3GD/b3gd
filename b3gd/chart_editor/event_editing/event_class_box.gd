extends OptionButton

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		var object_example = load(global_class.path).new()
		if object_example is Event:
			
			add_item(global_class.class)
			class_paths.append(global_class.path)
