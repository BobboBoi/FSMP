extends TextureButton
class_name ShuffleButton

@onready var player : Player = get_tree().get_first_node_in_group("Player")

@export var ShuffledTexture : Texture
@export var UnshuffledTexture : Texture

func _ready() -> void:
	player.QueueChange.connect(Refresh)
	Refresh()

func _pressed() -> void:
	player.Shuffle()
	Refresh()

func Refresh() -> void:
	if player.shuffled:
		texture_normal = ShuffledTexture
		tooltip_text = "Restore"
	else:
		texture_normal = UnshuffledTexture
		tooltip_text = "Shuffle"
