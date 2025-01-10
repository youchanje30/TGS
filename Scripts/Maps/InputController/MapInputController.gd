extends tick_IC
class_name map_IC

# for tile
@export var tile_id : ButtonData
@export var max_tick_data: ButtonData
@export var is_tick : Button
@export var event_data : LineEdit

func _ready() -> void:
	await super._ready()
	max_tick_data.cur = map_controller.mapdata.tick_time
	max_tick_data.text = str(max_tick_data.cur)

func act_input(pos : Vector2i):
	if is_tick.button_pressed:
		if is_remove.button_pressed:
			Tick_Remove(pos)
		else:
			Tick_Generate(pos)
	else:
		if is_remove.button_pressed:
			Tile_Remove(pos)
		else:
			Tile_Generate(pos)


func Tile_Generate(pos : Vector2i):
	var id = tile_id.cur
	if id < 8:
		map_controller.generate_tile(pos, id, event_data.text)
	else:
		map_controller.add_goal(pos)

func Tile_Remove(pos : Vector2i):
	map_controller.remove_tile(pos)

func _on_save_pressed() -> void:
	map_controller.save(max_tick_data.cur)

func _on_time_pressed(time : int) -> void:
	#select.set_max_time(max_tick_data.cur)
	map_controller.time_change(time)
