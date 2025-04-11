extends Control

@onready var window := get_window()
@onready var timer := Timer.new()
var fps := 0.
var windowMode := Window.Mode.MODE_WINDOWED

const MINIMIZED_FPS := 10

func _ready() -> void:
	fps = DisplayServer.screen_get_refresh_rate()
	add_child(timer)
	timer.start(1)
	timer.timeout.connect(PerformanceChecks)

func PerformanceChecks() -> void:
	var newFps := DisplayServer.screen_get_refresh_rate()
	if fps != newFps:
		print("FPS Change")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		await get_tree().process_frame
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		fps = newFps
	
	var newMode := window.mode
	if newMode != windowMode:
		print("Window Mode Change")
		OS.low_processor_usage_mode = newMode == Window.Mode.MODE_MINIMIZED
		windowMode = newMode
