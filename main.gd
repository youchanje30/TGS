extends Node2D

@export var controller : tile_DC

@onready var map_list: OptionButton = $"Map List"
@onready var load_button: Button = $"Load Button"
@onready var remove_button: Button = $"Remove Button"
@onready var remain_tick: Label = $remain_tick
@onready var type_select: OptionButton = $"Type Select"
@onready var clear_: Label = $clear_


var map = preload("res://Scenes/GameEditor/MapEditor.tscn")
var path = "res://Datas/MapData"
#var path = "res://Datas/MapData/Duplicate"

var remove_map = null






func _ready() -> void:
	select_type(0)


func add_map(pt):
	map_list.clear()
	var time = get_files_num(pt)
	for i in range(time):
		map_list.add_item(str(i))

	

func get_files_num(pt : String):
	var dir = DirAccess.open(pt)
	if not dir: return 0
	
	var num_of_file = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		num_of_file += 1	
		file_name = dir.get_next()
	return num_of_file

func get_map_data()->MapData:
	var index = map_list.get_selected_id()
	print(index)
	var add_path = type_select.get_item_text(type_select.get_selected_id())
	var pt = path + add_path
	var pre_path = pt + "/MapData_" + str(int(index/10)) + str(index%10)  + ".tres"
	print(pre_path)
	var data = load(pre_path)
	return data

func load_map():
	var maps = map.instantiate()
	maps.map_controller.mapdata = get_map_data()
	add_child(maps)
	remove_map = maps
	maps.map_controller.connect("clear", clear_maps)
	maps.connect("act_input_data", change_remain_tick)
	change_remain_tick()
	remove_button.visible = true

func change_remain_tick():
	remain_tick.text = "remain tick : " + str(remove_map.get_remain_tick())

func clear_maps():
	remove_button.visible = true
	clear_.visible = true

func active(view = false):
	map_list.visible = view
	load_button.visible = view
	remain_tick.visible = not view
	clear_.visible = false
	type_select.visible = view

func start_btn():
	controller.one_frame()


func remove_map_data() -> void:
	if remove_map == null: return
	remove_map.queue_free()
	remove_button.visible = false
	active(true)

func select_type(index):
	var add_path = type_select.get_item_text(index)
	var pt = path + add_path
	add_map(pt)

func _on_type_select_item_selected(index: int) -> void:
	select_type(index)
