@abstract class_name EventTween extends Event

@export var tween: bool = true
@export_range(0.0, 10.0, 0.0, "or_greater") var duration: float = 2.5
@export var transition: Tween.TransitionType = Tween.TRANS_QUINT
@export var ease_type: Tween.EaseType = Tween.EaseType.EASE_OUT
var tween_tracker = {
	"node": null,
	"property": null
}
var to_tween = {
	"node": null,
	"property": null,
	"value": null
}
var force_ignore = false
var multiply = false


func init():
	pass

func play(speed: float = 1.0):
	if speed < 0 or force_ignore:
		return
	
	if tween_tracker.node != null and tween_tracker.node.get(tween_tracker.property) != null:
		tween_tracker.node.get(tween_tracker.property).kill()
		tween_tracker.node.set(tween_tracker.property, null)
	
	var tween_value = to_tween.value
	if multiply:
		tween_value = to_tween.node.get(to_tween.property) * tween_value
	
	if !tween:
		to_tween.node.set(to_tween.property, tween_value)
		return
	var current_tween = parent.get_tree().create_tween()
	
	current_tween.tween_property(
		to_tween.node, 
		to_tween.property, 
		tween_value, 
		duration / speed
	).set_trans(transition).set_ease(ease_type)
	
	if tween_tracker.node != null:
		tween_tracker.node.set(tween_tracker.property, current_tween)
