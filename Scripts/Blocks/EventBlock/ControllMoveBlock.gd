extends IEventBlock

@export var type : int = 0
@export var data : int = 0

@export var tick_texture : Array[Texture2D]
var nanut_type = [4, 2, 1]

signal any_tick
var p_node : IMovableBlock

func _ready() -> void:
	p_node = get_parent()
	var controller = p_node.get_parent().get_parent()
	connect("any_tick", controller.do_select_tick)
	set_texture()

func Interact(): pass

func Act():
	var str_data = "0001 " + str(data)
	var tick_data = [type, p_node.get_pos(), str_data]
	
	emit_signal("any_tick", tick_data)
	
	# 회전 값에 따라 변경하는 코드 작성
	var rotate_time = p_node.get_rotate()
	data = (data + rotate_time + nanut_type[type]) % nanut_type[type]
	set_texture()


func get_data():
	var event_data = str(type) + str(data)
	return event_data
func set_data(event_data):
	type = int(event_data[0])
	data = int(event_data[1])
	set_texture()


func set_texture():
	self.texture = tick_texture[get_index_type()+data]

func get_index_type():
	if type == 0:
		return 0
	if type == 1:
		return 4
	if type == 2:
		return 6
