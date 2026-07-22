class_name EventCameraZoom extends EventTween

@export var target_zoom: Vector2 = Vector2.ONE
@export var multiplicative: bool = false

func init():
	if parent.get_tree().get_first_node_in_group("SceneCamera") == null:
		force_ignore = true
		return
	tween_tracker.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	tween_tracker.property = "zoom_tween"
	
	to_tween.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	to_tween.property = "zoom"
	to_tween.value = target_zoom
	
	multiply = multiplicative
