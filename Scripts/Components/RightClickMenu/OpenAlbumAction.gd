extends RightClickItem

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")
@onready var ctrlPanel = get_tree().get_first_node_in_group("ControlPanel")

func _pressed() -> void:
	assert(_NodeSupported(RightClick.hovered), "Open Album action does not support nodes of type: " + RightClick.hovered.get_class())
	
	if _NodeContainsMusicData(RightClick.hovered):
		var data = RightClick.hovered.data
		if data.album == "": return
		
		var albumData := Lister.GetAlbumData(data.album)
		if albumData == null: return
		
		var cover := await GetCover(albumData)
		if ctrlPanel.queuePanel.open:
			ctrlPanel.CloseQueue()
		if !home.visible:
			home.ShowHome()
		home.OpenAlbum(albumData,cover)
	
	else: 
		var data := TrackLister.CheckMusicData(RightClick.hovered.path)
		if data.album == "": return
		
		var albumData := Lister.GetAlbumData(data.album)
		if albumData == null: return
		
		var cover := await GetCover(albumData)
		home.ShowHome()
		home.OpenAlbum(albumData,cover)

func CheckVisibility(src : Node) -> void:
	if !_NodeSupported(src) or RightClick.selection.size() > 0: return
	
	# Check if item has an album
	if _NodeContainsMusicData(src):
		var data = src.data
		if data.album == "": return
	else:
		var data := TrackLister.CheckMusicData(src.path)
		if data.album == "": return
	
	show()

func GetCover(albumData : AlbumData) -> Texture2D:
	var cover := await Lister.LoadAlbumCover(albumData)
	if cover == null:
		return load("res://Assets/Sprites/Logo.png")
	return cover

func _NodeSupported(node : Node) -> bool:
	return node is QuickAccessButton or node is NewQuickAccessButton or _NodeContainsMusicData(node)

func _NodeContainsMusicData(node : Node) -> bool:
	return node is MusicSelection or node is QueueSelection
