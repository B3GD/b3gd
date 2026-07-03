class_name EventCameraRotate extends EventTween

@export_range(-360, 360, 0.0) var target_rotation: float = 0.0

func init():
	if parent.get_tree().get_first_node_in_group("SceneCamera") == null:
		force_ignore = true
		return
	tween_tracker.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	tween_tracker.property = "rotation_tween"
	
	to_tween.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	to_tween.property = "rotation_degrees"
	to_tween.value = target_rotation
