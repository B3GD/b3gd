class_name EventCallFunction extends Event

@export var node_path: String = ""
@export var function_name: String = ""
@export var function_parameters: String = ""
@export var add_speed: bool = true

var node: Node
func init():
	node = parent.get_tree().current_scene.get_node_or_null(node_path)

func play(speed: float = 1.0):
	var split_parameters = Array(function_parameters.split(",", false))
	assert(node != null, "Call function: Node" + node_path + "does not exist")
	if add_speed:
		split_parameters.insert(0, speed)
	var function_id = node.get_method_list().find_custom(func(x): return x.name == function_name)
	assert(function_id >= 0, "Call function: function" + function_name + "does not exist")
	var function_params = node.get_method_list()[function_id].args
	for param_id in split_parameters.size():
		var param = function_params[param_id]
		split_parameters[param_id] = type_convert(split_parameters[param_id], param.type)
	node.callv(function_name, split_parameters)
