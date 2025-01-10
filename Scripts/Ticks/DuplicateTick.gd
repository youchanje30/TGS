class_name DuplicateTick
extends ITick

# this tick is move tick
# move blocks at tick
var id = 2
@export var direction_info : Array[IDirection]
@export var texture : Texture2D

func tick(base_pos: Vector2i, data:String): pass
func event(base_pos: Vector2i, data:String):
	var sliced_data = data.split(" ", true, 1)
	for i in range(len(sliced_data[0])):
		if data[i] == "0": continue
		for add_pos in direction_info[i].direction:
			var pos = add_pos + base_pos
			emit_signal("do_tick", [id, pos])

func view(base_pos: Vector2i, data:String):
	super.view(base_pos, data)
	var sliced_data = data.split(" ", true, 1)
	for i in range(len(sliced_data[0])):
		if data[i] == "0": continue
		for add_pos in direction_info[i].direction:
			var pos = add_pos + base_pos
			var view_node = Sprite2D.new()
			view_node.texture = texture
			view_node.global_position = pos * 16
			emit_signal("tick_view", view_node)
