extends Panel
class_name QueueControls

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var controlPanel : ControlPanel = get_tree().get_first_node_in_group("ControlPanel")
@onready var list := %QueueList

var ignoreNextUpdate := false
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
	if ignoreNextUpdate: 
		ignoreNextUpdate = false
		return
	
	for i in list.get_children(): i.queue_free()
	
	for i in player.queue.size():
		var n := QueueSelection.Create(player.queue[i])
		list.add_child(n)
		n.Pressed.connect(player.TravelTo.bind(i))
	
	list.Update()

func ClearQueue() -> void:
	player.ClearQueue()

func ShuffleQueue() -> void:
	player.Shuffle()

func OnQueueItemMoved(originalIndex: int, newIndex: int) -> void:
	ignoreNextUpdate = true
	player.MoveItemInQueue(originalIndex,newIndex)

func OnItemMoved(item: Control, newIndex: int) -> void:
	if item is not HomeMenuItem: return
	item.Pressed.disconnect(player.TravelTo)
	item.Pressed.connect(player.TravelTo.bind(newIndex))

func SizeUpdate() -> void:
	if controlPanel == null: return
	custom_minimum_size.y = get_viewport().size.y - controlPanel.size.y
