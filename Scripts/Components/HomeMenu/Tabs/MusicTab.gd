extends Tab

@onready var lister := get_tree().get_first_node_in_group("Lister")
@onready var list := %MusicList

const THREAD_SLICE := 100

func _ready():
	lister.ListChanged.connect(Reload,CONNECT_DEFERRED)
	Reload()

func Reload():
	for i in list.get_children(): i.free()
	var threads : Array[Thread] = []
	
	#List Music
	for s in range(ceil(float(lister.music.size()) / THREAD_SLICE)):
		var t := Thread.new()
		t.start(AddMusicButtons.bind(lister.music.slice(THREAD_SLICE*s,THREAD_SLICE*(s+1))))
		threads.append(t)
	
	for t in threads:
		t.wait_to_finish()
	
	list.call_deferred("Update")

##Add home buttons for music in the given array
func AddMusicButtons(arr : Array[MusicData]) -> void:
	for i in arr:
		var butt := MusicSelection.Create(i)
		list.call_deferred_thread_group("add_child",butt)
		butt.ConnectToPlayTrack(home)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
