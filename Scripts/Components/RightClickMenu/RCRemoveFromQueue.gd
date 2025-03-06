extends RightClickItem

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	if owner is not RightClickMenu: return
	if !(owner.currentSelection is QueueSelection): return
	
	if owner.currentSelection == null:
		hide()
		return
	
	if Player.queue.size() > 0:
		Player.RemoveFromQueue(owner.currentSelection.queueIndex)

func _Show(src : Node) -> void:
	if owner is not RightClickMenu: return
	if !(src is QueueSelection): return
	show()
