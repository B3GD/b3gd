extends Node2D

func _ready() -> void:
	var offset = get_viewport().get_visible_rect().size / 2.0
	for child in get_children():
		child.scroll_offset = lerp(offset, Vector2.ZERO, child.scroll_scale.x)
