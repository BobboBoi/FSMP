extends Control
class_name HomeMenu

@onready var lister : TrackLister = %TrackLister
@onready var player : Player = %Player

@onready var tabCont : TabContainer = %TabCont
@onready var musicList := %MusicList
@onready var albumList := %AlbumList
@onready var albumMusicList := %AlbumMusicList

@onready var albumCover := %Cover
@onready var albumTitle := %Title

@onready var albumEdit := %EditAlbum

var selected : Array[HomeMenuItem] = []

enum TABS {
	MUSIC,
	ALBUM,
	ALBUM_MUSIC
}

const THREAD_SLICE := 100

signal SelectionUpdated

func _ready():
	visible = true
	tabCont.set_current_tab(TABS.MUSIC)
	
	Reload()
	
	lister.ListChanged.connect(Reload)
	player.NewTrack.connect(hideHome.unbind(1))

func Reload():
	for i in musicList.get_children(): i.free()
	for i in albumList.get_children(): i.free()
	
	var threads : Array[Thread] = []
	
	#List Music
	for s in range(ceil(float(lister.music.size()) / THREAD_SLICE)):
		var t := Thread.new()
		t.start(AddHomeButtons.bind(lister.music.slice(THREAD_SLICE*s,THREAD_SLICE*(s+1))))
		threads.append(t)
	
	for t in threads:
		t.wait_to_finish()
	
	#List Albums
	for i in lister.albums:
		var butt := AlbumSelection.Create(i)
		albumList.add_child(butt)
		butt.ConnectToAlbum(self)
		
		#Connect selection signals
		butt.Selected.connect(SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(UnselectedItem.bind(butt),CONNECT_DEFERRED)
	
	musicList.call_deferred("Update")
	albumList.Update()

##Add home buttons for music in the given array
func AddHomeButtons(arr : Array[MusicData]) -> void:
	for i in arr:
		var butt := MusicSelection.Create(i)
		musicList.call_deferred_thread_group("add_child",butt)
		butt.ConnectToPlayer(player)
		
		#Connect selection signals
		butt.Selected.connect(SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(UnselectedItem.bind(butt),CONNECT_DEFERRED)

func OpenAlbum(album : AlbumData):
	#Reset songlist
	for i in albumMusicList.get_children():
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
		albumMusicList.add_child(butt)
		butt.ConnectToPlayer(player)
		butt.button.connect("pressed",self.hideHome)
		butt.button.connect("pressed",self.ClearAlbumMusicList)
		
		#Connect selection signals
		butt.Selected.connect(SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(UnselectedItem.bind(butt),CONNECT_DEFERRED)
	
	#Load album info
	var file = FileAccess.open(album.cover, FileAccess.READ)
	if file != null:
		var bytes = file.get_buffer(file.get_length())
		var texture = Image.new()
		
		if bytes.size() > 0:
			if album.cover.ends_with(".png"):
				texture.load_png_from_buffer(bytes)
			elif album.cover.ends_with(".jpg"):
				texture.load_jpg_from_buffer(bytes)
			
			var final = ImageTexture.create_from_image(texture)
			albumCover.texture = final
	else:
		albumCover.texture = ImageTexture.create_from_image(load("res://Assets/Sprites/Logo.png").get_image())
	
	albumTitle.text = album.name
	albumMusicList.Update()
	
	tabCont.set_current_tab(TABS.ALBUM_MUSIC)

func ClearAlbumMusicList():
	for i in albumMusicList.get_children():
		i.queue_free()

func editPressed():
	$Edit.visible = !$Edit.visible

func setAlbumForAll():
	var arr : Array[MusicSelection] = []
	for i in musicList.get_children():
		if i is MusicSelection:
			if i.selected:
				arr.append(i)
	
	for i in arr:
		var newData := i.data
		newData.album = albumEdit.text
		Loader._save("user://Songs/"+newData.name,newData)
		i.data = newData
	
	#Load album data or create new data if it doesn't exist.
	var _garbo = lister.CheckAlbumData(albumEdit.text)

func showHome() -> void:
	self.visible = true
	tabCont.set_current_tab(TABS.MUSIC)

func hideHome() -> void:
	self.visible = false

#Music selection
func SelectedItem(item : HomeMenuItem):
	if selected.find(item) != -1: return
	selected.append(item)
	SelectionUpdated.emit()

func UnselectedItem(item : HomeMenuItem):
	var index := selected.find(item)
	if index == -1: return
	selected.remove_at(index)
	SelectionUpdated.emit()

func ClearSelection():
	for i in selected:
		i.Select(false)
