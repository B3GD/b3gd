extends PanelContainer

@export var header_label_settings: LabelSettings
@export var property_label_settings: LabelSettings

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var field_container = %EditorEventFieldContainer


var event_id = -1

func _process(delta: float) -> void:
	var new_event_id = %EditorEventContainer.event_selected
	if new_event_id == -1:
		event_id = new_event_id
		return
	if new_event_id != event_id:
		event_id = new_event_id
		update_event_info()

func update_event_info():
	var event = chart_source.chart.events[event_id]
	var event_name = event.get_script().get_global_name()
	var label = "id: " + str(event_id) + " - " + event_name
	%EditorEventHeader.text = label
	get_property_list()
	
	var export_properties = []
	
	var current_script_source = ""
	for property in event.get_property_list():
		if property.type == 0 and property.name.ends_with(".gd"):
			current_script_source = property.name
			export_properties.append({
				"is_category": true,
				"name": property.name
			})
			continue
		if current_script_source == "" or property.name.contains("/"):
			continue
		if !(property.usage & PROPERTY_USAGE_EDITOR): # Limit to export variables
			continue
		
		export_properties.append({
			"is_category": false,
			"name": property.name,
			"type": property.type,
			"hint": property.hint,
			"usage": property.usage
		})
	
	for child in field_container.get_children():
		field_container.remove_child(child)
	
	for property in export_properties:
		var name_label = Label.new()
		name_label.text = property.name
		
		if property.is_category:
			name_label.label_settings = header_label_settings
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			field_container.add_child(name_label)
			continue
		name_label.text = name_label.text.capitalize() + ": "
		name_label.label_settings = property_label_settings
		
		var hbox = HBoxContainer.new()
		field_container.add_child(hbox)
		hbox.add_child(name_label)
		
		match property.hint:
			PROPERTY_HINT_NONE:
				print(" --hint: no")
			PROPERTY_HINT_RANGE:
				print(" --hint: range")
			PROPERTY_HINT_ENUM:
				print(" --hint: enum")
		
		match property.type:
			TYPE_BOOL:
				var check_box = CheckBox.new()
				hbox.add_child(check_box)
			TYPE_INT:
				var spin_box = SpinBox.new()
				hbox.add_child(spin_box)
			_:
				var warn_label = Label.new()
				warn_label.text = "UNSUPPORTED TYPE"
				hbox.add_child(warn_label)
