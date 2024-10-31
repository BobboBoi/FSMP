extends Control
class_name HomeMenu

@onready var lister : TrackLister = %TrackLister
@onready var player : Player = %Player

@onready var tabCont : TabContainer = %TabCont
@onready var musicList := %MusicList
@onready var albumList := %AlbumList
@onready var albumMusicTab := %AlbumMusicTab

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
		var butt := AlbumSelection.Create(i,lister.LoadAlbumCover(i))
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


func OpenAlbum(albumData : AlbumData,cover : Texture2D):
	albumMusicTab.OpenAlbum(albumData,self,cover)
	tabCont.set_current_tab(TABS.ALBUM_MUSIC)

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
