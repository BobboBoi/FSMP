extends Panel
class_name QueueControls

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var controlPanel : ControlPanel = get_tree().get_first_node_in_group("ControlPanel")
@onready var list := %SongList

var open := false :
	set(value):
		if value: SizeUpdate()
		visible = value
		open = value

func _ready() -> void:
	player.QueueChange.connect(Refresh)
	hide()
	SizeUpdate()

func Refresh():
	for i in list.get_children(): i.queue_free()
	
	for i in player.queue:
		list.add_child(QueueSelection.Create(i))

func ClearQueue() -> void:
	player.ClearQueue()

func ShuffleQueue() -> void:
	player.Shuffle()

func SizeUpdate() -> void:
	if controlPanel == null: return
	custom_minimum_size.y = get_viewport().size.y - controlPanel.size.y
