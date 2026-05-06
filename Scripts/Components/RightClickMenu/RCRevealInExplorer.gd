extends RightClickItem

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	if owner is not RightClickMenu: return
	assert(_NodeSupported(owner.currentSelection), "Reveal in Explorer action does not support nodes of type: " + owner.get_class())
	
	if owner.currentSelection is MusicSelection or owner.currentSelection is QueueSelection:
		OS.shell_show_in_file_manager(owner.currentSelection.data.path, true)
	else: 
		OS.shell_show_in_file_manager(owner.currentSelection.path, true)

func _Show(src : Node) -> void:
	if owner is not RightClickMenu or !_NodeSupported(src) or home.selected.size() > 0: return
	
	if _NodeContainsMusicData(src):
		var data = src.data
		if data.album == "": return
	else:
		var data := TrackLister.CheckMusicData(src.path)
		if data.album == "": return
	
	show()

func _NodeSupported(node : Node) -> bool:
	return node is QuickAccessButton or node is NewQuickAccessButton or _NodeContainsMusicData(node)

func _NodeContainsMusicData(node : Node) -> bool:
	return node is MusicSelection or node is QueueSelection
