extends HBoxContainer

@export var timeline_present_point = 0.333
@export var strum_line_node: PackedScene
@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")


func _ready() -> void:
	update_strumlines()

func update_strumlines():
	for child in get_children():
		remove_child(child)
	
	for i in range(chart_source.chart.strum_lines.size()):
		var strum_line_source = chart_source.chart.strum_lines[i]
		var new_strumline = strum_line_node.instantiate()
		new_strumline.get_node("StrumLineRenderer").strum_line_idx = i
		new_strumline.get_node("%StrumLineLabel").text = str(i)
		new_strumline.get_node("%CPUCheckBox").button_pressed = strum_line_source.cpu
		new_strumline.get_node("%ReceptorCountSpinBox").value = strum_line_source.receptors.size()
		add_child(new_strumline)
