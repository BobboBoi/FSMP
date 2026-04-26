extends TextureButton
class_name PauseButton

func _ready() -> void:
	Player.Paused.connect(PlayerUpdate)
	Player.Resumed.connect(PlayerUpdate)
	PlayerUpdate()

func _pressed() -> void:
	if Player.stream_paused:
		Player.Resume()
	else:
		Player.Pause()

func PlayerUpdate() -> void:
	button_pressed = Player.stream_paused
