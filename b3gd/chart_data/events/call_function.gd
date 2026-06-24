class_name EventCallFunction extends Event

@export var node_path: String = ""
@export var function_name: String = ""
@export var function_parameters: String = ""

var node: Node
func init():
	node = parent.get_tree().current_scene.get_node_or_null(node_path)

func play(speed: float = 1.0):
	var split_parameters = Array(function_parameters.split(",", false))
	split_parameters.insert(0, speed)
	if node != null:
		node.callv(function_name, split_parameters)
