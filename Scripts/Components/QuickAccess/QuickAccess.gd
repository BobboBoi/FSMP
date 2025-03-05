extends Control
class_name QuickAccessMenu

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var listButton := %ListButton
@onready var searchbar := %Searchbar
@onready var list : SongList = %List
@onready var root := %Root

var threads : Array[Thread] = []
var status := STATES.CLOSED

enum STATES {
	OPEN,
	CLOSED
}

func _ready() -> void:
	Reload()
	lister.ListChanged.connect(Reload)

func _exit_tree() -> void:
	for t in threads:
		t.wait_to_finish()

func Reload() -> void:
	for i in list.get_children(): i.queue_free()
	await get_tree().process_frame
	threads = []
	
	for s in range(ceil(float(lister.music.size()) / 100)):
		var t := Thread.new()
		t.start(AddButtonsToMenu.bind(lister.music.slice(100*s,100*(s+1))),Thread.PRIORITY_LOW)
		threads.append(t)
	
	await get_tree().process_frame
	
	var butts : Array[QuickAccessButton] = []
	for t in threads:
		butts.append_array(await t.wait_to_finish())
	
	for b in butts:
		list.add_child(b)

func AddButtonsToMenu(arr : Array[MusicData]) -> Array[QuickAccessButton]:
	var butts : Array[QuickAccessButton] = []
	for i in arr:
		var butt := QuickAccessButton.new(i)
		butt.custom_minimum_size = Vector2(0,75)
		butt.ConnectToPlayer(player,self)
		butts.append(butt)
	return butts

func HideList() -> void:
	status = STATES.CLOSED
	%Vcont.hide()

func ShowList() -> void:
	status = STATES.OPEN
	%Vcont.show()

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

func SizeUpdate() -> void:
	if root == null: return
	root.size.x = size.x*root.anchor_right
	root.size.y = size.y
	
	if status == STATES.OPEN:
		root.position.x = 0
	else:
		root.position.x = -root.size.x
