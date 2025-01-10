extends Node2D
class_name tick_IC


var recent_time = 0

@export var map_controller: map_DC

@export var select : select_tick
@export var is_remove : Button
signal act_input_data

func _ready() -> void:
	await map_controller.ready()
	await select._ready()
	select.ready_max_time(map_controller.mapdata.tick_time)
	select.connect("time_change", _on_time_pressed)

func act_input(pos : Vector2i):
	if is_remove.button_pressed:
		Tick_Remove(pos)
	else:
		Tick_Generate(pos)
	emit_signal("act_input_data")

func get_remain_tick():
	return map_controller.mapdata.max_use_tick - map_controller.used_tick

func _process(delta: float) -> void:
	# 우클릭임
	if Input.is_action_just_pressed("click"):
		var posss = Vector2i(get_global_mouse_position()-Vector2(-8,-8))
		var pos = Vector2i(posss/16)
		act_input(pos)

func Tick_Generate(pos):
	var tick_data = select.get_tick_info(pos)
	var type = tick_data[1]
	var time = tick_data[2]
	var data = tick_data[3]
	map_controller.generate_tick(pos, type, time,  data)
	

func Tick_Remove(pos : Vector2i):
	var time = select.get_time()
	map_controller.remove_tick(pos, time)

func _on_time_pressed(time : int) -> void:
	map_controller.try_time_change(time)

func _on_do_pressed() -> void:
	map_controller.set_ingame()
	
	select.select_time(0)

func _on_reset_pressed() -> void:
	map_controller.set_resetgame()

func _on_out_pressed() -> void:
	map_controller.set_outgame()
	select._on_time_pressed(0)
