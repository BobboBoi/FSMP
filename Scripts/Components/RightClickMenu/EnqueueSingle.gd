extends RightClickItem

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	if owner is not RightClickMenu: return
	var hideHome := Player.queue.size() <= 0
	
	if owner.currentSelection is MusicSelection:
		Player.EnqueueFromDataArray([owner.currentSelection.data])
	elif owner.currentSelection is QuickAccessButton:
		Player.EnqueueFromPathArray([owner.currentSelection.path])
	else:
		return
	
	if !hideHome: return
	home.HideHome()

func _Show(src : Node) -> void:
	if owner is not RightClickMenu: return
	if !(src is MusicSelection or src is QuickAccessButton): return
	if home.selected.size() > 0: return
	show()
