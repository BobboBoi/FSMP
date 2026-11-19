extends RightClickItem

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	assert(_NodeSupported(RightClick.hovered), "Reveal in Explorer action does not support nodes of type: " + RightClick.get_class())
	
	if RightClick.hovered is MusicSelection or RightClick.hovered is QueueSelection:
		OS.shell_show_in_file_manager(RightClick.hovered.data.path)
	else: 
		OS.shell_show_in_file_manager(RightClick.hovered.path)

func CheckVisibility(src : Node) -> void:
	if !_NodeSupported(src) or RightClick.selection.size() > 0: return
	show()

func _NodeSupported(node : Node) -> bool:
	return node is QuickAccessButton or node is NewQuickAccessButton or _NodeContainsMusicData(node)

func _NodeContainsMusicData(node : Node) -> bool:
	return node is MusicSelection or node is QueueSelection
