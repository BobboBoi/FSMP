extends RichTextLabel

@onready var window : Window = get_window()

func _ready() -> void:
	Player.Resumed.connect(set_process.bind(true))
	Player.Paused.connect(set_process.bind(false))
	text = ""

func _process(_delta: float) -> void:
	if window.mode == window.Mode.MODE_MINIMIZED: return
	if Player.stream_paused: 
		set_process(false)
		return
	
	if Player.stream != null:
		text = ToSeconds(Player.get_playback_position())+" - "+ToSeconds(Player.stream.get_length())
	else:
		text = ""

func ToSeconds(value : float) -> String:
	var minutes := floori(value/60)
	var seconds := floori(value) - minutes*60
	return "%s:%s" % [minutes,("0" if seconds < 10 else "")+str(seconds)]
