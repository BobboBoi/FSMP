extends TextureButton
class_name ShuffleButton

@export var ShuffledTexture : Texture
@export var UnshuffledTexture : Texture

func _ready() -> void:
	Player.QueueChange.connect(Refresh)
	Refresh()

func _pressed() -> void:
	Player.Shuffle()
	Refresh()

func Refresh() -> void:
	if Player.shuffled:
		texture_normal = ShuffledTexture
		tooltip_text = "Restore"
	else:
		texture_normal = UnshuffledTexture
		tooltip_text = "Shuffle"
