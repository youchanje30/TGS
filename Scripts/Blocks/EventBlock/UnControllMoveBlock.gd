extends IEventBlock

@export var data : int = 0
@export var tick_texture : Array[Texture2D]

var p_node : IUnmovableBlock
var move_vector = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

func _ready() -> void:
	p_node = get_parent()
	set_texture()

func set_texture():
	self.texture = tick_texture[data]


func get_data():
	return str(data)
func set_data(event_data):
	data = int(event_data)
	set_texture()

func Interact(): pass

func Act(): p_node._add_move(move_vector[data])
