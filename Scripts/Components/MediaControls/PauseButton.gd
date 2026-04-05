extends TextureButton
class_name PauseButton

func _ready() -> void:
	Player.Paused.connect(PlayerUpdate)
	Player.Resumed.connect(PlayerUpdate)
	PlayerUpdate()

func _pressed() -> void:
	# might cause issues as it doesn't emit any Pause or Resume signals
	Player.stream_paused = button_pressed

func PlayerUpdate() -> void:
	button_pressed = Player.stream_paused
