extends RightClickItem

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	if owner is not RightClickMenu: return
	if !(owner.currentSelection is QueueSelection): return
	
	if owner.currentSelection == null:
		hide()
		return
	
	if player.queue.size() > 0:
		player.RemoveFromQueue(owner.currentSelection.queueIndex)

func _Show(src : Node) -> void:
	if owner is not RightClickMenu: return
	if !(src is QueueSelection): return
	show()
