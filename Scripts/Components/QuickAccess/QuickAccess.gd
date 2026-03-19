extends Control
class_name QuickAccessMenu

@onready var listButton := %ListButton
@onready var searchbar := %Searchbar
@onready var list : SongList = %List
@onready var root := %Root

#var threads : Array[Thread] = []
var status := STATES.CLOSED

enum STATES {
	OPEN,
	CLOSED
}

func _ready() -> void:
	Lister.ListChanged.connect(Reload.bind(searchbar.text))
	searchbar.text_changed.connect(Reload)
	%Vcont.hide()

#func _exit_tree() -> void:
	#for t in threads:
		#t.wait_to_finish()
	#
	#for i in list.get_children():
		#i.free()
	#await get_tree().process_frame

func Reload(q : String) -> void:
	print("Search ",q)
	for i in list.get_children(): i.queue_free()
	if q == "": return
	#await get_tree().process_frame
	#threads = []
	#
	#for s in range(ceil(float(Lister.music.size()) / 100)):
		#var t := Thread.new()
		#t.start(AddButtonsToMenu.bind(Lister.music.slice(100*s,100*(s+1))),Thread.PRIORITY_LOW)
		#threads.append(t)
	#
	#await get_tree().process_frame
	#
	#var butts : Array[QuickAccessButton] = []
	
	#for t in range(threads.size()):
		#butts.append_array(await threads.front().wait_to_finish())
		#threads.remove_at(0)
	
	var t := Thread.new()
	t.start(AddButtonsToMenu.bind(q, Thread.PRIORITY_LOW))
	await t.wait_to_finish()
	
	#for i in Lister.music.filter(func(t : MusicData): return t.name.to_lower().find(q.to_lower()) != -1):
		#var b := QuickAccessButton.new(i)
		#b.custom_minimum_size = Vector2(0,75)
		#b.ConnectToPlayer(self)
		#list.add_child(b)

func AddButtonsToMenu(q : String) -> void:#Array[QuickAccessButton]:
	#var butts : Array[QuickAccessButton] = []
	
	for i in Lister.music.filter(func(m : MusicData): return m.name.to_lower().find(q.to_lower()) != -1):
		var butt := QuickAccessButton.new(i)
		butt.set_deferred("custom_minimum_size",Vector2(0,75))
		butt.ConnectToPlayer.bind(self).call_deferred()
		#butts.append(butt)
		list.add_child.bind(butt).call_deferred()

func HideList() -> void:
	status = STATES.CLOSED
	Reload("")
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
	root.size.x = size.x * root.anchor_right
	root.size.y = size.y
	
	if status == STATES.OPEN:
		root.position.x = 0
	else:
		root.position.x = -root.size.x
