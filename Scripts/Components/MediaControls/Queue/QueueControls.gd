extends Control
class_name QueueControls

@onready var speenLoad := preload("res://Scenes/Components/SpinyDisc.tscn")
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
	Player.QueueChange.connect(Refresh)
	Player.QueueProgressed.connect(ProgressQueue)
	hide()

func Refresh():
	await get_tree().process_frame
	for i in list.get_children(): i.free()
	
	for i in Player.queue.size():
		var n := QueueSelection.Create(Player.queue[i],i)
		list.add_child(n)
		n.Pressed.connect(Player.TravelTo.bind(i))
		
		if(Player.currentIndex) == i:
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
	Player.MoveItemInQueue(originalIndex,newIndex)

func OnItemMoved(item: Control, newIndex: int) -> void:
	if item is not HomeMenuItem: return
	item.Pressed.disconnect(Player.TravelTo)
	item.Pressed.connect(Player.TravelTo.bind(newIndex))
