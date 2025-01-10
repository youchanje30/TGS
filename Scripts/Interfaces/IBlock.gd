class_name IBlock
extends ITGS

#region Block Data
var cur_pos : Vector2i
@export var id : int
@export var event_blocks : Array[IEventBlock]
var block_data
#endregion

#region Move Data
var move_position : Vector2i
var rotate_time : int # 0 = 0, 90 = 1, 180 = 2, 270 = 3.. always % 4
#endregion

func _ready() -> void:
	reset_tick()

#region Base Block Function
func Act()->void:
	for event_block in event_blocks: event_block.Act()

func Interact()->void:
	for event_block in event_blocks: event_block.Interact()

func set_pos(pos : Vector2i):
	self.global_position = pos * 16
	cur_pos = pos

func get_pos()->Vector2i:
	return cur_pos

func get_block_data():
	var data = str(block_data)
	for event_block in event_blocks:
		data += " " +event_block.get_data()
	return data

func set_block_data(data):
	var sliced_data = data.split(" ", true)
	block_data = sliced_data[0]
	for i in range(event_blocks.size()):
		event_blocks[i].set_data(sliced_data[i+1])
#endregion


#region Move Function
func real_move():
	var pos = get_total_position()
	if pos.x < 0 or pos.x >= 100 or pos.y < 0 or pos.y >= 100: return
	set_next_position()
	reset_tick()

func reset_tick() -> void:
	move_position = Vector2i.ZERO
	rotate_time = 0

func _add_move(add: Vector2i):
	move_position += add
func _add_rotate(add: int):
	rotate_time = (rotate_time + 4 + add) % 4

# about total pos
func get_pos_rotate(vector : Vector2i, i : int):
	var x : int = vector.x
	var y : int = vector.y
	match i%4:
		0:
			return Vector2i(x, y)
		1:
			return Vector2i(-y, x)
		2:
			return Vector2i(-x, -y)
		3:
			return Vector2i(y, -x)
	return Vector2i(x, y)

func get_total_position():
	return get_pos() + get_pos_rotate(move_position, rotate_time)

func set_next_position():
	var total_pos = get_total_position()
	if get_pos() != total_pos: print(get_pos(), " to ", total_pos)
	set_pos(total_pos)

func get_rotate():
	return rotate_time
#endregion
