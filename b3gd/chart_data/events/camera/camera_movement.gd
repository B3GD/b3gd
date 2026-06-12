class_name EventCameraMovement extends EventTween

@export var target_idx: int

var target: Vector2

func init():
	if parent.get_tree().get_first_node_in_group("CameraTargets") == null:
		force_ignore = true
		return
	if parent.get_tree().get_first_node_in_group("SceneCamera") == null:
		force_ignore = true
		return
	target = parent.get_tree().get_first_node_in_group("CameraTargets").get_children()[target_idx].global_position
	
	tween_tracker.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	tween_tracker.property = "position_tween"
	
	to_tween.node = parent.get_tree().get_first_node_in_group("SceneCamera")
	to_tween.property = "position"
	to_tween.value = target
