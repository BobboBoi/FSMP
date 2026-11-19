extends RightClickItem

func _pressed() -> void:
	assert(_NodeSupported(RightClick.hovered), "RemoveFromQueue action does not support nodes of type: " + RightClick.hovered.get_class())
	
	if RightClick.hovered == null:
		hide()
		return
	
	if Player.queue.size() > 0:
		Player.RemoveFromQueue(RightClick.hovered.queueIndex)

func CheckVisibility(src : Node) -> void:
	if !_NodeSupported(src): return
	show()

func _NodeSupported(node : Node) -> bool:
	return node is QueueSelection
