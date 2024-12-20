extends TextureButton
class_name ClearButton

@onready var player : Player = get_tree().get_first_node_in_group("Player")

func _pressed() -> void:
	player.ClearQueue()
