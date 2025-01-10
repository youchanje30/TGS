class_name ITick
extends ITGS

signal tick_view
signal do_tick
@export var highlight_tick : Texture2D
# this class only use for interfaces

func tick(base_pos: Vector2i, data:String): pass
func event(base_pos: Vector2i, data:String): pass
func view(base_pos: Vector2i, data:String):
	var view_node = Sprite2D.new()
	view_node.texture = highlight_tick
	view_node.global_position = base_pos * 16
	emit_signal("tick_view", view_node)
