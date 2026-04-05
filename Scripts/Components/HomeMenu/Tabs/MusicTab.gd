extends Tab

@onready var list := %MusicList
@onready var search := %SearchBar

const THREAD_SLICE := 100

var threads : Array[Thread] = []

func _exit_tree() -> void:
	for t in threads:
		t.wait_to_finish()
	
	for i in list.get_children():
		i.free()

func _ready() -> void:
	Lister.ListChanged.connect(%LoadingSpinner.hide)
	Lister.ReloadStarted.connect(%LoadingSpinner.show.unbind(1))
	
	Lister.ListChanged.connect(%Scroll.show)
	Lister.ReloadStarted.connect(%Scroll.hide.unbind(1))
	
	Lister.ListChanged.connect(Reload)
	Lister.ReloadStarted.connect(Clear.unbind(1))

func _OnTabClosed() -> void:
	if !is_inside_tree(): return
	search.text = ""

func Clear() -> void:
	for i in list.get_children(): 
		i.queue_free()

func Reload() -> void:
	for t in threads:
		t.wait_to_finish()
	threads = []
	
	#List Music
	for s in range(ceil(float(Lister.music.size()) / THREAD_SLICE)):
		var t := Thread.new()
		threads.push_back(t)
		t.start(CreateMusicButtons.bind(Lister.music.slice(THREAD_SLICE*s,THREAD_SLICE*(s+1))), Thread.PRIORITY_NORMAL)
	
	# Instantiate buttons
	var butts : Array[MusicSelection] = []
	for t in range(threads.size()):
		butts.append_array(threads.front().wait_to_finish())
		threads.remove_at(0)
	
	await get_tree().process_frame
	
	# Add buttons
	for b in butts:
		list.add_child(b)
		ConnectButton(b)
	
	list.Update()

## Create home buttons for music in the given array
func CreateMusicButtons(arr : Array[MusicData]) -> Array[MusicSelection]:
	var butts : Array[MusicSelection] = []
	for i in arr:
		var butt := MusicSelection.Create(i)
		butts.append(butt)
	
	return butts

func ConnectButton(butt : MusicSelection) -> void:
	#Connect selection signals
	butt.ConnectToPlayTrack(home)
	butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
	butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
