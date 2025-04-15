extends Control

@onready var controlPanel : ControlPanel = get_tree().get_first_node_in_group("ControlPanel")

func _ready() -> void:
	controlPanel.resized.connect(SizeUpdate)
	#controlPanel.minimum_size_changed.connect(MinSizeUpdate)
	SizeUpdate()

func SizeUpdate() -> void:
	if controlPanel.mediaControlPanel == null: await controlPanel.ready
	custom_minimum_size = controlPanel.mediaControlPanel.size

func MinSizeUpdate() -> void:
	if controlPanel.mediaControlPanel == null: await controlPanel.ready
	custom_minimum_size = controlPanel.mediaControlPanel.custom_minimum_size
