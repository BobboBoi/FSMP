extends Control

@onready var window := get_window()
@onready var timer := Timer.new()
var resolution := Vector2i.ZERO
var fps := 0.
var windowMode := Window.Mode.MODE_WINDOWED

const fullscreenMode := Window.MODE_FULLSCREEN

func _ready() -> void:
	resolution = DisplayServer.screen_get_size()
	
	# Prevent the application from becoming to small at higher resolutions
	if resolution.y >= 2160 and resolution.x >= 3840:
		window.content_scale_factor = 1.5
		window.size *= 1.5
	
	fps = DisplayServer.screen_get_refresh_rate()
	add_child(timer)
	timer.start(1)
	timer.timeout.connect(PerformanceChecks)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Fullscreen"):
		if window.mode == fullscreenMode:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = fullscreenMode
		
		windowMode = window.mode
		window.set_input_as_handled()

func PerformanceChecks() -> void:
	var newFps := DisplayServer.screen_get_refresh_rate()
	if fps != newFps:
		print("FPS Change: %s -> %s" % [fps, newFps])
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		await get_tree().process_frame
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		fps = newFps
	
	var newMode := window.mode
	if newMode != windowMode:
		print("Window Mode Change")
		OS.low_processor_usage_mode = newMode == Window.Mode.MODE_MINIMIZED
		windowMode = newMode
