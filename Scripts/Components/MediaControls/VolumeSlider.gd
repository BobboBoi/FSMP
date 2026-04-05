extends HBoxContainer
class_name VolumeSlider

@onready var icon := %Icon
@onready var slider := %Slider
@onready var icons := {
	&"mute": preload("uid://bxnk34v0hs4i7"),
	&"high": preload("uid://cnrgsc6le0q1v"),
	&"mid": preload("uid://defea6dbuel2a"),
	&"low": preload("uid://yaysrabxut1v")
}

@export var targetBus := 0

func _ready() -> void:
	slider.value = Loader.config.volume

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"Mute"):
		OnIconClicked(event)
		get_window().set_input_as_handled()

func UpdateIcon() -> void:
	if AudioServer.is_bus_mute(0):
		icon.texture = icons[&"mute"]
	elif slider.value > 0.66:
		icon.texture = icons[&"high"]
	elif slider.value > 0.33:
		icon.texture = icons[&"mid"]
	elif slider.value > 0:
		icon.texture = icons[&"low"]

func ValueChanged(value: float) -> void:
	AudioServer.set_bus_volume_db(targetBus, linear_to_db(value))
	AudioServer.set_bus_mute(targetBus, value <= 0.)
	UpdateIcon()

func Save(value : float) -> void:
	Loader.config.volume = slider.value
	Loader.Save(Loader.configPath, Loader.config)

func OnIconClicked(event: InputEvent) -> void:
	if event.is_action_pressed(&"LeftClick"):
		AudioServer.set_bus_mute(targetBus, !AudioServer.is_bus_mute(targetBus))
		UpdateIcon()
