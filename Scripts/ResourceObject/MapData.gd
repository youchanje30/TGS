class_name MapData extends Resource

@export var block_data : Array[Array] # pos, type
@export var tick_data : Array[Array] # pos, type, time(index), data(string)

@export var goal_data : Array[Vector2i] # just pos

@export var tick_time : int = 10 # map's tick time
@export var max_use_tick : int # map's max tick per time
