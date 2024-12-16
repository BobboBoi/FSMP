extends Control

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var queuePanel := %QueuePanel
@onready var mainCont := %MainCont
@onready var list := %SongList

var queueOpen := false :
	set(value):
		if mainCont != null: queuePanel.visible = value
		queueOpen = value


func _ready() -> void:
	player.QueueChange.connect(Refresh)
	queuePanel.hide()
	SizeUpdate()

func Refresh():
	for i in list.get_children(): i.queue_free()
	
	for i in player.queue:
		list.add_child(QueueSelection.Create(i.name))

func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and queueOpen:
		CloseQueue()
		get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("QuickAccess") and queueOpen:
		CloseQueue()
		get_viewport().set_input_as_handled()

func ToggleQueue():
	if queueOpen: CloseQueue()
	else: OpenQueue()

func OpenQueue() -> void:
	SizeUpdate()
	
	queueOpen = true
	var tween := create_tween()
	tween.tween_property(mainCont,"position",Vector2(0,-queuePanel.size.y),0.4)

func CloseQueue() -> void:
	var tween := create_tween()
	tween.tween_property(mainCont,"position",Vector2(0,0),0.3)
	tween.tween_callback(self.set.bind("queueOpen",false))

func SizeUpdate() -> void:
	if queuePanel == null: return
	queuePanel.custom_minimum_size.y = get_viewport().size.y - self.size.y

func ClearQueue() -> void:
	player.ClearQueue()

func ShuffleQueue() -> void:
	player.Shuffle()
