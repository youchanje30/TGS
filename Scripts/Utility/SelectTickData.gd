class_name select_tick
extends Node

signal time_change

@export var time_info : OptionButton
@export var type_info : OptionButton
@export var dir_info : OptionButton
@export var self_info : OptionButton # 0 - no , 1 - yes
@export var RotateType : Array[OptionButton]

func _ready() -> void: pass

func ready_max_time(max_val : int):
	for i in range(max_val):
		time_info.add_item(str(i))

func get_time():
	return time_info.get_selected_id()
	

func set_max_time(max_val : int):
	pass
	#time_info.max_cur = max_val

func get_tick_info(pos : Vector2i):
	var time = get_time()
	var type = type_info.get_item_id(type_info.selected)
	var direction = dir_info.get_item_id(dir_info.selected)
	
	var self_check = self_info.get_item_id(self_info.selected)
	var add = RotateType[type].get_item_id(RotateType[type].selected)
	add = get_tick_rotate(type, add)
	var add_data = get_dir(direction)+str(self_check) + " " + str(add)
	var tick_data = [pos, type, time, add_data]
	return tick_data

func get_dir(i : int):
	if i == 0: return "000"
	if i == 1: return "100"
	if i == 2: return "010"
	if i == 3: return "001"
	return ""

func get_tick_rotate(i : int, id : int):
	if i == 1: return id-2
	return id

func _on_type_item_selected(index: int) -> void:
	for i in range(len(RotateType)):
		RotateType[i].visible = false
	RotateType[index].visible = true

func _on_time_pressed(index: int) -> void:
	select_time(index)
	emit_signal("time_change", index)
	
func select_time(i):
	time_info.select(i)
