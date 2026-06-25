extends Node

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")

func _on_save_button_pressed() -> void:
	#backs up last chart with a _old on the end in case something went south.
	var dir_access = DirAccess.open("res://")
	dir_access.rename(chart_source.chart.resource_path, chart_source.chart.resource_path + "_old")
	ResourceSaver.save(chart_source.chart, chart_source.chart.resource_path)
