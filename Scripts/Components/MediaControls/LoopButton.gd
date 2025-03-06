extends TextureButton
class_name LoopButton

@export var LoopQueueTexture : Texture2D
@export var LoopSingleTexture : Texture2D
@export var NoLoopTexture : Texture2D

func _ready() -> void:
	Refresh()

func _pressed() -> void:
	Player.loopMode = Player.LOOPMODE.get(Player.LOOPMODE.find_key(wrapi(Player.loopMode + 1,0,Player.LOOPMODE.size())))
	Refresh()

func Refresh() -> void:
	match(Player.loopMode):
		MusicPlayer.LOOPMODE.LOOP_QUEUE:
			texture_normal = LoopQueueTexture
			tooltip_text = "Looping Queue"
		MusicPlayer.LOOPMODE.LOOP_SINGLE:
			texture_normal = LoopSingleTexture
			tooltip_text = "Looping Track"
		MusicPlayer.LOOPMODE.NO_LOOP:
			texture_normal = NoLoopTexture
			tooltip_text = "No Loop"
