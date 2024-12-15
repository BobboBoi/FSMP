extends TextureButton

@onready var player : Player = get_tree().get_first_node_in_group("Player")

@export var LoopQueueTexture : Texture2D
@export var LoopSingleTexture : Texture2D
@export var NoLoopTexture : Texture2D

func _ready() -> void:
	Refresh()

func _pressed() -> void:
	player.loopMode = Player.LOOPMODE.get(Player.LOOPMODE.find_key(wrapi(player.loopMode + 1,0,Player.LOOPMODE.size())))
	Refresh()

func Refresh() -> void:
	match(player.loopMode):
		Player.LOOPMODE.LOOP_QUEUE:
			texture_normal = LoopQueueTexture
			tooltip_text = "Looping Queue"
		Player.LOOPMODE.LOOP_SINGLE:
			texture_normal = LoopSingleTexture
			tooltip_text = "Looping Track"
		Player.LOOPMODE.NO_LOOP:
			texture_normal = NoLoopTexture
			tooltip_text = "No Loop"
