extends SplitContainer

@export var strumline_node: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_strumlines():
	for child in get_children():
		if child.name.begins_with("_"):
			continue
		remove_child(child)
	
