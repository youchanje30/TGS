extends tile_DC
class_name map_DC

var path = "res://Datas/MapData/Normal"
var save_path = ""
var isPlay = false

var used_tick = 0


#region about goal
var goal_pos = []
@export var goal : Node
@export var goal_texture : Texture2D
#endregion

func ready() -> void:
	if mapdata == null:
		mapdata = MapData.new()
		new_save_path()
	else:
		save_path = mapdata.resource_path
	var t_time = mapdata.tick_time
	mapdata.tick_time = 10
	await super.ready()
	mapdata.tick_time = t_time
	goal_pos = mapdata.goal_data
	used_tick = len(mapdata.tick_data)
	view_goal()

func new_save_path():
	save_path = path + "/MapData_" + str(get_files_num(path)) +".tres"

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

func save(max_tick : int = 10):
	mapdata.block_data = []
	for tile_data in tiles:
		for tile in tile_data:
			mapdata.block_data.append([tile.get_pos(), tile.id, tile.get_block_data()])
	mapdata.goal_data = []
	for pos in goal_pos:
		mapdata.goal_data.append(pos)
	save_tick()

	mapdata.tick_time = max(max_tick, 1)
	ResourceSaver.save(mapdata, save_path)

func save_tick():
	mapdata.tick_data = []
	for time in range(mapdata.tick_time):
		for tick in tick_datas[time]:
			var pos = tick[0]
			var type = tick[1]
			var data = tick[2]
			mapdata.tick_data.append([pos, type, time, data])


func set_ingame():
	one_frame()
	isPlay = true

func set_outgame():
	cur_time = 0
	save_tick()
	clear_maps()
	load_maps()
	isPlay = false
	view_ticks(0)

func set_resetgame():
	used_tick = 0
	set_array(tick_datas, mapdata.tick_time, 0, 0)
	set_outgame()


#region tick
func generate_tick(pos : Vector2i, type : int, time : int,  data : String):
	if isPlay: return
	if used_tick >= mapdata.max_use_tick: return
	if is_exist_tick(pos, time): return
	tick_datas[time].append([pos, type, data])
	time_change(time)
	used_tick += 1

func remove_tick(pos:Vector2i, time:int):
	if isPlay: return
	if not is_exist_tick(pos, time): return
	used_tick -= 1
	tick_datas[time].erase(get_tick(pos, time))
	time_change(time)

func set_ticks_view(is_view, time = 0) -> void:
	if is_view:
		view_ticks(time)
	else:
		remove_view_tick()
#endregion


#region tile
func remove_tile(pos : Vector2i):
	remove_goal(pos)
	remove_tile_auto(pos)

func generate_tile(pos : Vector2i, id : int, event_data):
	remove_tile(pos)
	fill_tile(pos, id, event_data)
	add_tile_auto(pos)
#endregion

func add_goal(pos: Vector2i):
	if is_exist_tile(pos): return
	if pos in goal_pos: return
	goal_pos.append(pos)
	view_goal()

func remove_goal(pos):
	if pos in goal_pos: goal_pos.erase(pos)
	view_goal()

func time_change(time:int):
	set_ticks_view(false, time)
	set_ticks_view(true, time)

func try_time_change(time):
	if isPlay: return
	time_change(time)

func view_goal():
	for ett in goal.get_children(): ett.queue_free()
	for pos in goal_pos:
		var g = Sprite2D.new()
		g.texture = goal_texture
		g.global_position = pos * 16
		goal.add_child(g)
