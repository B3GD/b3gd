extends PanelContainer

@export var header_label_settings: LabelSettings
@export var property_label_settings: LabelSettings
@export var error_label_settings: LabelSettings

@onready var chart_source = get_tree().get_first_node_in_group("ChartSource")
@onready var field_container = %EditorEventFieldContainer

var event_id = -1
var event_param_info = {}

const vector_members = ["x", "y", "z", "w"]

func _process(delta: float) -> void:
	var new_event_id = %EditorEventContainer.event_selected
	if new_event_id == -1:
		event_id = new_event_id
		event_param_info.clear()
		hide()
		return
	if new_event_id != event_id:
		event_id = new_event_id
		show()
		update_event_info()

func update_event_info():
	var event = chart_source.chart.events[event_id]
	var event_name = event.get_script().get_global_name()
	var label = "id: " + str(event_id) + " - " + event_name
	%EditorEventHeader.text = label
	
	var export_properties = []
	
	var current_script_source = ""
	for property in event.get_property_list():
		if property.type == 0 and property.name.ends_with(".gd"):
			current_script_source = property.name
			if property.name == "event.gd":
				continue
			export_properties.append({
				"is_category": true,
				"name": property.name
			})
			continue
		if current_script_source in ["", "event.gd"] or property.name.contains("/"):
			continue
		if !(property.usage & PROPERTY_USAGE_EDITOR): # Limit to export variables
			continue
		
		export_properties.append({
			"is_category": false,
			"name": property.name,
			"type": property.type,
			"hint": property.hint,
			"hint_string": property.hint_string,
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
		
		var enum_values = {}
		var range_options = {}
		match property.hint:
			PROPERTY_HINT_NONE:
				pass
			PROPERTY_HINT_RANGE:
				var range_string = property.hint_string.split(",")
				range_options.lower = float(range_string[0])
				range_options.upper = float(range_string[1])
				range_options.step = 1.0
				range_options.allow_lesser = range_string.has("or_lesser")
				range_options.allow_greater = range_string.has("or_greater")
				if range_string.size() > 2:
					range_options.step = float(range_string[2])
			PROPERTY_HINT_ENUM:
				# "Zero,One,Three:3,Four,Six:6"
				var enum_string = property.hint_string.split(",")
				for value in enum_string:
					value = value.split(":")
					enum_values.set(value[0], int(value[1]))
		
		var hbox = HBoxContainer.new()
		field_container.add_child(hbox)
		hbox.add_child(name_label)
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var value = event.get(property.name)
		
		var inputs = []
		
		match property.type:
			TYPE_BOOL:
				var check_box = CheckBox.new()
				check_box.button_pressed = value
				inputs.append([check_box, ""])
				check_box.toggled.connect(value_changed.bind(check_box))
			TYPE_INT, TYPE_FLOAT:
				if enum_values.keys().size() == 0:
					var spin_box = init_spin_slider(range_options, property.type == TYPE_INT)
					spin_box.value = value
					inputs.append([spin_box, ""])
					spin_box.value_changed.connect(value_changed.bind(spin_box))
				else:
					var option_button = OptionButton.new()
					for key in enum_values.keys():
						option_button.add_item(key, enum_values[key])
					option_button.selected = value
					inputs.append([option_button, ""])
					option_button.item_selected.connect(value_changed.bind(option_button))
			TYPE_STRING:
				var line_edit = LineEditNoFocus.new()
				line_edit.text = value
				inputs.append([line_edit, ""])
				line_edit.text_changed.connect(value_changed.bind(line_edit))
			TYPE_COLOR:
				var color_picker = ColorPickerButton.new()
				color_picker.color = value
				inputs.append([color_picker, ""])
				color_picker.color_changed.connect(value_changed.bind(color_picker))
			TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4, TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
				var count = 2
				if property.type == TYPE_VECTOR3 or property.type == TYPE_VECTOR3I:
					count = 3
				if property.type == TYPE_VECTOR4 or property.type == TYPE_VECTOR4I:
					count = 4
				
				for i in count:
					var spin_box = init_spin_slider()
					spin_box.value = value[vector_members[i]]
					inputs.append([spin_box, "." + vector_members[i]])
					spin_box.value_changed.connect(value_changed.bind(spin_box))
			_:
				var warn_label = Label.new()
				warn_label.text = "UNSUPPORTED TYPE"
				warn_label.label_settings = error_label_settings
				hbox.add_child(warn_label)
		
		for input in inputs:
			input[0].size_flags_horizontal = Control.SIZE_EXPAND_FILL
			input[0].focus_behavior_recursive = Control.FOCUS_BEHAVIOR_DISABLED
			event_param_info.set(input[0], property.name + input[1])
			hbox.add_child(input[0])

func init_spin_slider(range_options: Dictionary = {}, force_int = false) -> SpinSlider:
	var spin_box = SpinSlider.new()
	spin_box.min_value = range_options.lower if range_options.has("lower") else 0.0
	spin_box.max_value = range_options.upper if range_options.has("upper") else 10.0
	spin_box.step = range_options.step if range_options.has("step") else 0.0
	spin_box.allow_lesser = range_options.allow_lesser if range_options.has("allow_lesser") else true
	spin_box.allow_greater = range_options.allow_greater if range_options.has("allow_greater") else true
	spin_box.show_range = range_options.keys().size() > 0
	if force_int:
		spin_box.step = 1.0
	return spin_box

func get_value(source: Node) -> Variant:
	var string = event_param_info[source].split(".")
	if string.size() > 1:
		return chart_source.chart.events[event_id].get(string[0])[string[1]]
	return chart_source.chart.events[event_id].get(string[0])

func value_changed(new_value: Variant, source: Node):
	var string = event_param_info[source].split(".")
	if string.size() > 1: # This is only vectors BTW
		var new_vector = chart_source.chart.events[event_id].get(string[0])
		new_vector[string[1]] = new_value
		chart_source.chart.events[event_id].set(string[0], new_vector)
	else:
		chart_source.chart.events[event_id].set(string[0], new_value)
