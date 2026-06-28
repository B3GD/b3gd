extends OptionButton

@export var hidden_classes: PackedStringArray

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		if load(global_class.path).new() is Note:
			if global_class.class in hidden_classes:
				continue
			add_item(global_class.class)
			class_paths.append(global_class.path)
