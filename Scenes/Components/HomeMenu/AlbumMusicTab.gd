extends Control

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var player : Player = get_tree().get_first_node_in_group("Player")

@onready var scrollBar : VScrollBar = %Scroll.get_v_scroll_bar()
@onready var list : SongList = %AlbumMusicList
@onready var cover := %AlbumCover
@onready var title := %Title

const SENSITIVITY := 1.5

func _ready() -> void:
	$AnimationPlayer.current_animation = "Scroll"
	$AnimationPlayer.stop(true)
	scrollBar.value_changed.connect(ScrollChanged)

func OpenAlbum(album : AlbumData, home : HomeMenu,newCover : Texture2D = null):
	#Reset songlist
	for i in list.get_children():
		if i is MusicSelection:
				i.free()
	
	#Fetch Songs
	var files : Array = []
	for i in lister.music:
			if i.album == album.name:
				files.append(i)
	
	#Load Saved Data
	for i in files:
		var butt := MusicSelection.Create(i,i.albumIndex)
		list.add_child(butt)
		butt.ConnectToPlayer(player)
		butt.button.connect("pressed",home.hideHome)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
	
	cover.texture = newCover
	title.text = album.name
	list.Update()


func ScrollChanged(value : float):
	if !visible: return
	$AnimationPlayer.seek(clamp(value/scrollBar.page*SENSITIVITY,0.0,1.0),true,true)

func _on_hidden() -> void:
	for i in list.get_children():
		i.queue_free()
