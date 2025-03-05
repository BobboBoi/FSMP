extends Tab

@onready var lister : TrackLister
@onready var player : Player

@onready var scrollBar : VScrollBar = %Scroll.get_v_scroll_bar()
@onready var list : SongList = %AlbumMusicList
@onready var cover := %AlbumCover
@onready var title := %Title

const SENSITIVITY := 1.5

func _ready() -> void:
	lister = home.lister
	player = home.player
	
	$AnimationPlayer.current_animation = "Scroll"
	$AnimationPlayer.stop(true)
	scrollBar.value_changed.connect(ScrollChanged)

func _OnTabClosed() -> void:
	if list == null: return
	for i in list.get_children(): i.queue_free()

func OpenAlbum(album : AlbumData, newHome : HomeMenu, newCover : Texture2D = null) -> void:
	#Reset songlist
	for i in list.get_children():
		if i is MusicSelection:
				i.free()
	
	if lister == null:
		home = newHome
		lister = home.lister
		player = home.player
	
	#Fetch Songs
	var files : Array = []
	for i in lister.music:
			if i.album == album.name:
				files.append(i)
	
	#Load Saved Data
	for i in files:
		var butt := MusicSelection.Create(i,i.albumIndex)
		list.add_child(butt)
		butt.ConnectToPlayTrack(home)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
	
	cover.texture = newCover
	title.text = album.name
	$AnimationPlayer.seek(0.0,true,true)
	
	list.Update()

func EnqueueAll() -> void:
	if list.get_child_count() <= 0: return
	
	var data : Array[MusicData] = []
	for i in list.get_children():
		if i is MusicSelection:
			data.append(i.data)
	
	var hideHome := player.queue.size() > 0
	player.EnqueueFromDataArray(data)
	if !hideHome: return
	home.HideHome()

func PlayAll() -> void:
	if list.get_child_count() <= 0: return
	
	var data : Array[MusicData] = []
	for i in list.get_children():
		if i is MusicSelection:
			data.append(i.data)
	
	player.ReplaceQueueWithDataArray(data)
	home.HideHome()

func ScrollChanged(value : float) -> void:
	if !visible: return
	$AnimationPlayer.seek(clamp(value/scrollBar.page*SENSITIVITY,0.0,1.0),true,true)
