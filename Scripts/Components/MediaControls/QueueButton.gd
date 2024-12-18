extends BaseButton
class_name QueueButton

func _ready() -> void:
	var mediaTab = get_tree().get_first_node_in_group("ControlPanel")
	if mediaTab != null:
		pressed.connect(mediaTab.ToggleQueue)
