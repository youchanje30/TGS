extends Node
class_name tile_DC

@export var mapdata : MapData
@export var ticks : Array[ITick]

@export var block_view: Node
@export var tick_view: Node

signal clear

var base_tile = [
# 컨트롤 가능
preload("res://Scenes/Blocks/Controll/ControllBlock.tscn"),
preload("res://Scenes/Blocks/Controll/MoveControllBlock.tscn"),
preload("res://Scenes/Blocks/Controll/DuplicateControllBlock.tscn"),
preload("res://Scenes/Blocks/Controll/DuplicateControllBlock.tscn"), # rotate

# 컨트롤 불가능
preload("res://Scenes/Blocks/UnControll/MoveUncontrollBlock.tscn"),
preload("res://Scenes/Blocks/UnControll/BreakUncontrollBlock.tscn"),
preload("res://Scenes/Blocks/UnControll/BreakMoveUncontrollBlock.tscn"),
preload("res://Scenes/Blocks/UnControll/WallUncontrollBlock.tscn")
]

var tiles = [[], [], [], [], [], [], [], [], []]

@export var cur_map = [] # 현재 맵에 있는 정보를 저장, 이전 정보 저장을 위해 2개 사용
var tick_datas = []
var cur_time = 0
var dup_tiles_data = [] # pos, id

#region Utility
func add_dic(dic : Dictionary, data):
	dic[data] = data
func set_array(arr : Array, r : int, size : int, val):
	arr.resize(0)
	for i in range(r):
		arr.append([])
		arr[i].resize(size)
		arr[i].fill(val)
func is_exist(obj):
	return obj != null and not obj.is_queued_for_deletion()
#endregion

func connect_signal():
	for tick in ticks:
		tick.connect("tick_view", view_tick)
		tick.connect("do_tick", do_any_tick)

func ready() -> void:
	connect_signal()
	if mapdata == null:
		print("No MapData")
		get_tree().quit()
		return
	load_maps()

func is_clear():
	if not check_goal(): return
	emit_signal("clear")

func clear_maps():
	for block in block_view.get_children():
		block.queue_free()
	remove_view_tick()

#region about Tile
func get_tile(pos):
	return cur_map[pos.x][pos.y]
func is_exist_tile(pos) -> bool:
	return is_exist(get_tile(pos))
func is_exist_IMovable_tile(pos) -> bool:
	var tile = get_tile(pos)
	return is_exist(tile) and tile is IMovableBlock

func fill_tile(pos : Vector2i, id : int, event_data):
	var tile = spawn_tile(id, event_data)
	tile.set_pos(pos)
	cur_map[pos.x][pos.y] = tile

func spawn_tile(id : int, event_data):
	var tile = base_tile[id].instantiate()
	tile.set_block_data(event_data)
	block_view.add_child(tile)
	return tile

func get_index_from_tile_id(tile)->int:
	return tile.id

func add_tiles_auto(pos_list)->void:
	for pos in pos_list: add_tile_auto(pos)
func add_tile_auto(pos)->void:
	if not is_exist_tile(pos): return 
	var tile = get_tile(pos)
	tiles[get_index_from_tile_id(tile)].append(tile)

func remove_tile_auto(pos):
	if not is_exist_tile(pos): return
	var tile = get_tile(pos)
	tiles[get_index_from_tile_id(tile)].erase(tile)
	set_null_tile(get_tile(pos))
	tile.queue_free()

func add_IMovable_tiles(tiles_pos):
	while tiles_pos: add_IMovable_tile(tiles_pos.pop_back())
func add_IMovable_tile(pos):
	if not is_exist_IMovable_tile(pos): return
	tiles[0].append(get_tile(pos))

func get_all_IMovable_Tiles_and_set_null():
	var data = []
	while tiles[0]:
		var tile = tiles[0].pop_back()
		data.append(tile)
		set_null_tile(tile)
	return data

func get_tiles_and_set_null():
	var data = []
	for tile_list in tiles:
		while tile_list:
			var tile = tile_list.pop_back()
			data.append(tile)
			set_null_tile(tile)
	return data

func remove_all_repeat_tiles(tiles):
	while tiles:
		var tile = tiles.pop_back()
		var pos = tile.get_pos()
		tile.Interact()
		if tile is IMovableBlock:
			tile.queue_free()
		set_null_pos_if_not_exist(pos)

func set_null_all_tiles(tiles):
	while tiles: set_null_tile(tiles.pop_back())

func set_null_pos_if_not_exist(pos : Vector2i):
	if not is_exist_tile(pos): set_null_pos(pos)

func set_null_tile(tile):
	if not is_exist(tile): return
	set_null_pos(tile.get_pos())

func set_null_pos(pos : Vector2i):
	cur_map[pos.x][pos.y] = null
#endregion

#region about Ticks
# act all cur_time's ticks
func event_tick():
	for tick_data in tick_datas[cur_time]:
		var pos = tick_data[0]
		var type = tick_data[1]
		var bin_data = tick_data[2]
		ticks[type].event(pos, bin_data)

	# 신규 기능 Act
	for tile_list in tiles:
		for tile in tile_list:
			tile.Act()

func view_ticks(time = cur_time):
	for tick_data in tick_datas[time]:
		var pos = tick_data[0]
		var type = tick_data[1]
		var bin_data = tick_data[2]
		ticks[type].view(pos, bin_data)

func view_tick(tick):
	tick_view.add_child(tick)

func remove_view_tick():
	for tick in tick_view.get_children(): tick.queue_free()

func is_exist_tick(pos : Vector2i, time : int)->bool:
	for exist_data in tick_datas[time]:
		var exist_pos = exist_data[0]
		if pos == exist_pos: return true
	return false

func get_tick(pos : Vector2i, time : int):
	for tick in tick_datas[time]:
		var tick_pos = tick[0]
		if tick_pos == pos: return tick
#endregion

func load_maps():
	set_array(cur_map, 100, 100, null)
	set_array(tiles, base_tile.size(), 0, 0)
	set_array(tick_datas, mapdata.tick_time, 0, 0)

	# 블럭 추가
	for data in mapdata.block_data:
		var pos = data[0]
		var type = data[1]
		var block_data = data[2]
		fill_tile(pos, type, block_data)
		add_tile_auto(pos)

	for data in mapdata.tick_data:
		var pos = data[0]
		var type = data[1]
		var time = data[2]
		var binarydata = data[3]
		tick_datas[time].append([pos, type, binarydata])

	# 틱 보여주기
	view_ticks()

func check_goal() -> bool:
	for pos in mapdata.goal_data:
		if not is_exist_IMovable_tile(pos): return false
	return true

func one_frame():
	remove_view_tick()
	event_tick()
	do_tick()
	view_ticks()
	# 클리어 여부 출력
	print("goal is " + str(check_goal()))
	is_clear()

#region Time Process
func tiles_move(tile_list, pos_dic, remove_dic):
	while tile_list:
		var tile = tile_list.pop_back()
		tile.real_move()
		var pos = tile.get_pos()
		add_dic(pos_dic, pos)
		# 타일이 있으면 제거 처리
		if is_exist_tile(pos):
			add_dic(remove_dic, tile)
			add_dic(remove_dic, get_tile(pos))
		else:
			cur_map[pos.x][pos.y] = tile

func tiles_duplicate(pos_dic, remove_dic):
	while dup_tiles_data:
		var data = dup_tiles_data.pop_back()
		var pos = data[0]
		var id = data[1]
		var event_data = data[2]

		if is_exist_tile(pos):
			add_dic(remove_dic, get_tile(pos))
			var dup_tile = spawn_tile(id, event_data)
			dup_tile.set_pos(pos)
			add_dic(remove_dic, dup_tile)
			continue

		# 복제된 곳에 블럭이 없을 때
		fill_tile(pos, id, event_data)
		add_dic(pos_dic, pos)

func do_tick():
	# 블럭 위치 모두 받고 null로 변경 후 이동 해야함
	var next_time = (cur_time + 1) % mapdata.tick_time

	# 모든 타일을 받음
	var cur_tile_list = get_tiles_and_set_null()
	# 제거 해야하는 타일들
	var remove_tile_dict = {}
	# 다음에 존재하는 위치들
	var next_tile_pos_dict = {}

	tiles_duplicate(next_tile_pos_dict, remove_tile_dict)
	tiles_move(cur_tile_list, next_tile_pos_dict, remove_tile_dict)
	remove_all_repeat_tiles(remove_tile_dict.keys())
	add_tiles_auto(next_tile_pos_dict.keys())

	# 시간은 다음 시간으로 계속
	cur_time = next_time
#endregion

#region Tick Process
func do_select_tick(tick_data):
	var type = tick_data[0]
	var pos = tick_data[1]
	var bin_data = tick_data[2]
	ticks[type].event(pos, bin_data)

func do_any_tick(tick_data):
	var type = tick_data.pop_front()
	if type == 0:
		move_tick(tick_data)
	elif type == 1:
		rotate_tick(tick_data)
	else:
		duplicate_tick(tick_data)

func move_tick(data):
	var pos = data[0]
	var move_vec = data[1]
	if not is_exist_IMovable_tile(pos): return
	var select_tile = get_tile(pos)
	select_tile._add_move(move_vec)

func rotate_tick(data):
	var pos = data[0]
	var rotate_time = data[1]
	if not is_exist_IMovable_tile(pos): return
	var select_tile = get_tile(pos)
	select_tile._add_rotate(rotate_time)

func duplicate_tick(data):
	var pos = data[0]
	if not is_exist_IMovable_tile(pos): return
	var select_tile = get_tile(pos)
	var id = select_tile.id
	dup_tiles_data.append([pos, id, select_tile.get_block_data()])
#endregion
