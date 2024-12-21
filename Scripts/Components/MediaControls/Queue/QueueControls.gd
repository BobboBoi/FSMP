extends Control
class_name QueueControls

@onready var speenLoad := preload("res://Scenes/Components/SpinyDisc.tscn")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var controlPanel : ControlPanel = get_tree().get_first_node_in_group("ControlPanel")
@onready var list := %QueueList

var currentlyPlaying : QueueSelection = null
var currentSpeen : SpinyDisc = null
var ignoreNextUpdate := false
var open := false :
	set(value):
		visible = value
		open = value

func _ready() -> void:
	player.QueueChange.connect(Refresh)
	player.QueueProgressed.connect(ProgressQueue)
	hide()

func Refresh():
	for i in list.get_children(): i.queue_free()
	
	for i in player.queue.size():
		var n := QueueSelection.Create(player.queue[i])
		list.add_child(n)
		n.Pressed.connect(player.TravelTo.bind(i))
		
		if(player.currentIndex) == i:
			currentlyPlaying = n
			Speen(n)
	
	list.Update()

func ProgressQueue(index : int):
	currentlyPlaying = list.get_child(index)
	Speen(currentlyPlaying)

func Speen(new : QueueSelection):
	if currentSpeen != null:
		currentSpeen.free()
	
	currentSpeen = speenLoad.instantiate()
	new.get_node("%SpinParent").add_child(currentSpeen)

func OnQueueItemMoved(originalIndex: int, newIndex: int) -> void:
	player.MoveItemInQueue(originalIndex,newIndex)

func OnItemMoved(item: Control, newIndex: int) -> void:
	if item is not HomeMenuItem: return
	item.Pressed.disconnect(player.TravelTo)
	item.Pressed.connect(player.TravelTo.bind(newIndex))
