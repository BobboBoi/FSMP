extends Control
class_name HomeMenu

@onready var lister : TrackLister = %TrackLister
@onready var player : Player = %Player

@onready var tabCont : TabContainer = %TabCont
@onready var musicTab := %MusicTab
@onready var albumTab := %AlbumTab
@onready var albumMusicTab := %AlbumMusicTab

@onready var albumEdit := %EditAlbum

var selected : Array[HomeMenuItem] = []

enum TABS {
	MUSIC,
	ALBUM,
	ALBUM_MUSIC
}

signal SelectionUpdated

func _ready():
	visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		get_parent().select_previous_available()
		get_viewport().set_input_as_handled()

func OpenAlbum(albumData : AlbumData,cover : Texture2D):
	albumMusicTab.OpenAlbum(albumData,self,cover)
	tabCont.set_current_tab(TABS.ALBUM_MUSIC)

func ShowHome() -> void:
	self.visible = true
	tabCont.set_current_tab(TABS.MUSIC)

func HideHome() -> void:
	self.visible = false

#Player actions
func PlayTrack(data : MusicData) -> void:
	player.PlaySingleFromData(data)
	HideHome()

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

#region deprecated
##@deprecated
func EditPressed():
	$Edit.visible = !$Edit.visible
##@deprecated
func SetAlbumForAll():
	pass
	var musicList = Node.new()
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
#endregion
