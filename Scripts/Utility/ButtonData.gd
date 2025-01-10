class_name ButtonData
extends Button

@export var max_cur : int = 5
var cur : int = 0

func _ready() -> void:
	text = str(cur)

func _pressed() -> void:
	cur = (cur+1) % max_cur
	text = str(cur)
