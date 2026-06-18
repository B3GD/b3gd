class_name EventTween extends Event

@export var tween: bool
@export var duration: float
@export var transition: Tween.TransitionType
@export var ease: Tween.EaseType

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


func init():
	pass

func play(speed: float = 1.0):
	if speed < 0 or force_ignore:
		return
	
	if tween_tracker.node != null and tween_tracker.node.get(tween_tracker.property) != null:
		tween_tracker.node.get(tween_tracker.property).kill()
		tween_tracker.node.set(tween_tracker.property, null)
	
	if !tween:
		to_tween.node.set(to_tween.property, to_tween.value)
		return
	var tween = parent.get_tree().create_tween()
	tween.tween_property(
		to_tween.node, 
		to_tween.property, 
		to_tween.value, 
		duration / speed
	).set_trans(transition).set_ease(ease)
	
	if tween_tracker.node != null:
		tween_tracker.node.zoom_tween = tween
