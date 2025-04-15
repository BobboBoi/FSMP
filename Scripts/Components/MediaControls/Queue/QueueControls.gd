extends Control
class_name QueueControls

@onready var speenLoad := preload("res://Scenes/Components/SpinyDisc.tscn")
@onready var controlPanel : ControlPanel = get_tree().get_first_node_in_group("ControlPanel")
@onready var scroll : SmoothScrollContainer = %Scroll
@onready var list := %QueueList

var currentlyPlaying : QueueSelection = null
var currentSpeen : SpinyDisc = null
var ignoreNextUpdate := false
var open := false :
	set(value):
		visible = value
		open = value

func _exit_tree() -> void:
	for i in list.get_children():
		i.free()
	await get_tree().process_frame

func _ready() -> void:
	Player.QueueChange.connect(Refresh)
	Player.QueueProgressed.connect(ProgressQueue)
	hide()

func Refresh():
	await get_tree().process_frame
	for i in list.get_children(): i.free()
	
	var rect := scroll.get_rect()
	rect.position.y = scroll.scroll_vertical
	var numb := 0
	for i in Player.queue.size():
		var n := QueueSelection.Create(Player.queue[i],i)
		list.add_child(n)
		n.Pressed.connect(Player.TravelTo.bind(i))
		
		#Force the text that is in view to immediatly show
		#In this case 4 is the seperation of the boxcontainer
		var nRect := n.get_rect()
		nRect.position.y += (nRect.size.y+4) * numb
		if nRect.intersects(rect):
			n.VisUpdate(true, false)
			if(Player.currentIndex) == i:
				Speen.call_deferred(n)
		
		if(Player.currentIndex) == i:
			currentlyPlaying = n
			n.ContentLoaded.connect(Speen.bind(n))
		
		numb += 1
	
	list.Update()

func ProgressQueue(index : int):
	currentlyPlaying = list.get_child(index)
	Speen(currentlyPlaying)

func Speen(new : QueueSelection):
	if currentSpeen != null:
		currentSpeen.free()
	
	currentSpeen = speenLoad.instantiate()
	new.get_node("Cont/SpinParent").add_child(currentSpeen)

func OnQueueItemMoved(originalIndex: int, newIndex: int) -> void:
	Player.MoveItemInQueue(originalIndex,newIndex)

func OnItemMoved(item: Control, newIndex: int) -> void:
	if item is not HomeMenuItem: return
	item.Pressed.disconnect(Player.TravelTo)
	item.Pressed.connect(Player.TravelTo.bind(newIndex))
