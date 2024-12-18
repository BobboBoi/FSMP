extends Control
class_name QuickAccessMenu

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var listButton := %ListButton
@onready var searchbar := %Searchbar
@onready var list := %List
@onready var root := %Root

var status := STATES.CLOSED
enum STATES {
	OPEN,
	CLOSED
}

func _ready() -> void:
	Reload()
	lister.ListChanged.connect(Reload)

func Reload() -> void:
	for i in list.get_children(): i.free()
	
	var threads : Array[Thread] = []
	
	for s in range(ceil(float(lister.music.size()) / 100)):
		var t := Thread.new()
		t.start(AddButtonsToMenu.bind(lister.music.slice(100*s,100*(s+1))))
		threads.append(t)
	
	for t in threads:
		t.wait_to_finish()
	
	list.call_deferred("Update")

func AddButtonsToMenu(arr : Array[MusicData]) -> void:
	for i in arr:
		var butt := QuickAccessButton.new(i)
		butt.custom_minimum_size = Vector2(0,75)
		butt.ConnectToPlayer(player)
		list.call_deferred_thread_group("add_child",butt)

func OnListButtonPressed() -> void:
	if !visible: return
	
	var tween := create_tween()
	if root.position.x == 0:
		searchbar.release_focus()
		tween.tween_property(root,"position",Vector2(-root.size.x as float,0),0.4)
		tween.tween_callback(HideList)
		listButton.text = ">"
	else:
		searchbar.grab_focus()
		tween.tween_property(root,"position",Vector2(0.0,0.0),0.4)
		ShowList()
		listButton.text = "<"

func HideList():
	status = STATES.CLOSED
	%Vcont.hide()

func ShowList():
	status = STATES.OPEN
	%Vcont.show()

func SizeUpdate() -> void:
	if root == null: return
	root.size.x = size.x*root.anchor_right
	root.size.y = size.y
	
	if status == STATES.OPEN:
		root.position.x = 0
	else:
		root.position.x = -root.size.x
