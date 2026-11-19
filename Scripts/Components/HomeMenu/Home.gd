extends Control
class_name HomeMenu

@onready var tabCont : TabContainer = %TabCont
@onready var musicTab := %MusicTab
@onready var albumTab := %AlbumTab
@onready var albumMusicTab := %AlbumMusicTab

@onready var albumEdit := %EditAlbum

enum TABS {
	MUSIC,
	ALBUM,
	ALBUM_MUSIC
}

func _ready() -> void:
	Player.NewQueue.connect(HideHome)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		get_parent().select_previous_available()
		get_viewport().set_input_as_handled()

func OpenAlbum(albumData : AlbumData,cover : Texture2D):
	albumMusicTab.OpenAlbum(albumData,self,cover)
	tabCont.set_current_tab(TABS.ALBUM_MUSIC)

func OpenAlbumSelection(album : AlbumSelection):
	albumMusicTab.OpenAlbum(album.data,self,album.cover)
	tabCont.set_current_tab(TABS.ALBUM_MUSIC)

func ShowHome() -> void:
	self.visible = true
	tabCont.set_current_tab(TABS.MUSIC)

func HideHome() -> void:
	self.visible = false
	
	if tabCont == null:
		await tree_entered
	
	tabCont.set_current_tab(TABS.MUSIC)
