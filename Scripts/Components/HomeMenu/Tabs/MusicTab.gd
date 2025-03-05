extends Tab

@onready var lister := get_tree().get_first_node_in_group("Lister")
@onready var list := %MusicList
@onready var search := %SearchBar

const THREAD_SLICE := 100

var threads : Array[Thread] = []

func _ready():
	lister.ListChanged.connect(Reload)
	Reload()

func _exit_tree() -> void:
	for t in threads:
		t.wait_to_finish()

func _OnTabClosed():
	if !is_inside_tree(): return
	search.text = ""

func Reload():
	for i in list.get_children(): i.queue_free()
	threads = []
	
	#List Music
	for s in range(ceil(float(lister.music.size()) / THREAD_SLICE)):
		var t := Thread.new()
		threads.push_back(t)
		t.start(AddMusicButtons.bind(lister.music.slice(THREAD_SLICE*s,THREAD_SLICE*(s+1))),Thread.Priority.PRIORITY_LOW)
	
	await get_tree().process_frame
	
	var butts : Array[MusicSelection] = []
	for t in threads:
		butts.append_array(await t.wait_to_finish())
	
	for b in butts:
		list.add_child(b)
	
	list.call_deferred("Update")

##Add home buttons for music in the given array
func AddMusicButtons(arr : Array[MusicData]) -> Array[MusicSelection]:
	var butts : Array[MusicSelection] = []
	for i in arr:
		var butt := MusicSelection.Create(i)
		ConnectButton(butt)
		butts.append(butt)
	return butts

func ConnectButton(butt : MusicSelection) -> void:
	#Connect selection signals
	butt.ConnectToPlayTrack(home)
	butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
	butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
