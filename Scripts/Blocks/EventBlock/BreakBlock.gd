extends IEventBlock

@export var hp : int = 3

func Interact():
	hp -= 1
	if hp > 0: return
	print("hp가 없어서 삭제됨", owner.name)
	owner.queue_free()
	

func Act(): pass
