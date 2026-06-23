extends HBoxContainer

@export var strum_line_node: PackedScene
@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")

func _ready() -> void:
	update_strumlines()

func update_strumlines():
	#if get_children().size() - 1 == chart_source.chart.strum_lines.size():
	#	return
	
	for child in get_children():
		remove_child(child)
	
	for i in range(chart_source.chart.strum_lines.size()):
		var new_strumline = strum_line_node.instantiate()
		new_strumline.get_node("StrumLineRenderer").strum_line_idx = i
		new_strumline.get_node("%StrumLineLabel").text = "StrumLine " + str(i)
		add_child(new_strumline)
