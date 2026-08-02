extends OptionButton


@export var hidden_classes: PackedStringArray
@export var script_path: String

var class_paths = []

func _ready() -> void:
	for global_class in ProjectSettings.get_global_class_list():
		if not ResourceLoader.exists(global_class.path):
			continue
		
		var loaded_class := load(global_class.path)
		if loaded_class != null && does_script_extend_class(loaded_class, script_path):
			if global_class.class in hidden_classes:
				continue
			
			add_item(global_class.class)
			class_paths.append(global_class.path)
	
	selected = -1

func does_script_extend_class(base_script: Script, class_script_path: String) -> bool:
	var current: Script = base_script
	
	while current != null:
		if current.get_path() == class_script_path:
			return true
		
		current = current.get_base_script()
	
	return false
