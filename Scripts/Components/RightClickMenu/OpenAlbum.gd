extends RightClickItem

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _pressed() -> void:
	if owner is not RightClickMenu: return
	
	if owner.currentSelection is MusicSelection:
		var data = owner.currentSelection.data
		if data.album == "": return
		
		var albumData := lister.GetAlbumData(data.album)
		if albumData == null: return
		
		var cover := GetCover(albumData)
		home.OpenAlbum(albumData,cover)
	
	elif owner.currentSelection is QuickAccessButton:
		var data := TrackLister.CheckMusicDataFromPath(owner.currentSelection.path)
		if data.album == "": return
		
		var albumData := lister.GetAlbumData(data.album)
		if albumData == null: return
		
		var cover := GetCover(albumData)
		home.ShowHome()
		home.OpenAlbum(albumData,cover)
	else:
		return

func _Show(src : Node) -> void:
	if owner is not RightClickMenu: return
	if !(src is MusicSelection or src is QuickAccessButton): return
	if home.selected.size() > 0: return
	
	if src is MusicSelection:
		var data = src.data
		if data.album == "": return
	elif src is QuickAccessButton:
		var data := TrackLister.CheckMusicDataFromPath(src.path)
		if data.album == "": return
	
	show()

func GetCover(albumData : AlbumData) -> Texture2D:
	var cover := lister.LoadAlbumCover(albumData)
	if cover == null:
		return load("res://Assets/Sprites/Logo.png")
	return cover
