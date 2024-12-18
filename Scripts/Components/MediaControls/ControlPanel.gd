extends Control
class_name ControlPanel
##The main controls for the currently playing music.

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var queuePanel := %QueuePanel
@onready var mainCont := %MainCont

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and queuePanel.open:
		CloseQueue()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("QuickAccess") and queuePanel.open:
		CloseQueue()
		get_viewport().set_input_as_handled()

func ToggleQueue():
	if queuePanel.open: CloseQueue()
	else: OpenQueue()

func OpenQueue() -> void:
	queuePanel.open = true
	var tween := create_tween()
	tween.tween_property(mainCont,"position",Vector2(0,-queuePanel.size.y),0.4)

func CloseQueue() -> void:
	var tween := create_tween()
	tween.tween_property(mainCont,"position",Vector2(0,0),0.3)
	tween.tween_callback(queuePanel.set.bind("open",false))
