extends RightClickItem
class_name EnqueueNextButton
## Enqueues the current selection of the [RightClickMenu] and puts it behind the currently playing track

func _pressed() -> void:
	# Enqueue selection
	if RightClick.selection.size() > 0:
		var data : Array[MusicData] = []
		for d in RightClick.selection:
			if d is MusicSelection:
				data.append(d.data)
		
		Player.EnqueueNextFromDataArray(data)
		RightClick.ClearSelection()
		return
	
	# If there is no selection check if the hovered item is suppoerted
	assert(_NodeSupported(RightClick.hovered), "EnqueueNext action does not support nodes of type: " + RightClick.hovered.get_class())
	
	# Enqueue hovered (single item)
	if _NodeContainsMusicData(RightClick.hovered):
		Player.EnqueueNextFromData(RightClick.hovered.data)
	else:
		Player.EnqueueNextFromPath(RightClick.hovered.path)

func CheckVisibility(src : Node) -> void:
	if !_NodeSupported(src) and RightClick.selection.size() <= 0: return
	if RightClick.selection.size() > 0 and !_NodeSupported(RightClick.selection.front()): return
	show()

func _NodeSupported(node : Node) -> bool:
	return node is QuickAccessButton or node is NewQuickAccessButton or _NodeContainsMusicData(node)

func _NodeContainsMusicData(node : Node) -> bool:
	return node is MusicSelection
