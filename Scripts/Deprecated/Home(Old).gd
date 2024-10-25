extends Control

var current = "Music"
@onready var loadSelect = preload("res://FSMP/MusicSelection.tscn")

func _ready():
	visible = true
	
	setAlbumForAll()
	
	var files : Array = []
	for i in $Music/SongList.get_children():
		if !i is Label:
			if i.album != "":
				if files.find(i.album) == -1:
					files.append(i.album)
	var numb = 0
	for i in files:
		var select = load("res://FSMP/AlbumSelection.tscn").instantiate()
		var loaded = Loader._load("user://Albums/"+i)
		select.init(loaded.cover,loaded.name,loaded.artists)
		if numb % 2 != 0:
			select.get_node("ColorRect").color = Color(0.1,0.1,0.1,1)
		$Albums/SongList.add_child(select)
		select.get_node("Button").connect("pressed",Callable(self,"openAlbum").bind(select.albumName))
		numb += 1

func openAlbum(album):
	#Reset songlist
	for i in $AlbumSong/SongList.get_children():
		if i is MusicSelection:
				i.queue_free()
	
	#Fetch Songs
	var files : Array = []
	for i in $Music/SongList.get_children():
		if !i is Label:
			if i.album == album:
				files.append(Loader._load("user://Songs/"+i.songName))
	
	#Load Saved Data
	for i in files:
		var song = loadSelect
		song = song.instantiate()
		song.init(i.index,i.name,i.artist,i.album,i.path)
		$AlbumSong/SongList.add_child(song)
		song.get_node("Button").connect("pressed",Callable(get_node("../"),"play").bind(i.path,i.name,i.album))
		song.get_node("Button").connect("pressed",self.hideHome)
	
	#Load album info
	var loaded = Loader._load("user://Albums/"+album)
	if loaded != null:
		var file = FileAccess.open(loaded.cover, FileAccess.READ);
		if file != null:
			var bytes = file.get_buffer(file.get_length())
			var texture = Image.new()
			if bytes.size() > 0:
				if loaded.cover.ends_with(".png"):
					texture.load_png_from_buffer(bytes)
				elif loaded.cover.ends_with(".jpg"):
					texture.load_jpg_from_buffer(bytes)
				file.close()
				var final = ImageTexture
				final = final.create_from_image(texture)
				var cover = $AlbumSong/SongList/AlbumInfo/Hcont/Cover
				cover.texture = final
				#cover.scale = Vector2(cover.texture.get_width()/(128*1.9) as float,128*1.9 as float/cover.texture.get_height())
	
	$AlbumSong/SongList.sort()
	$AlbumSong/SongList/AlbumInfo/Hcont/Title.text = album
	
	$Albums.visible = false
	$AlbumSong.visible = true

func editPressed():
	$Edit.visible = !$Edit.visible

func setAlbumForAll():
	var arr : Array = []
	for i in $Music/SongList.get_children():
		if !i is Label:
			if i.get_node("CheckBox").button_pressed:
				arr.append(i)
	
	for i in arr:
		var loaded = Loader._load("user://Songs/"+i.songName)
		loaded.album = $Edit/AlbumAll/TextEdit.text
		Loader._save("user://Songs/"+i.songName,loaded)
		i.album = $Edit/AlbumAll/TextEdit.text
		i.get_node("Album").text = i.album
	
	var albums : Array = []
	for i in $Music/SongList.get_children():
		if !i is Label:
			if i.album != "":
				var loaded = Loader._load("user://Albums/"+i.album)
				if loaded == null:
					loaded = load("res://Store/Album.gd").new()
					loaded.name = i.album
					Loader._save("user://Albums/"+i.album,loaded)
				if loaded.cover == "":
					var dir = DirAccess.open("{IMG PATH}")
					
					dir.list_dir_begin()
					
					while true:
						var file = dir.get_next()
						if file == "":
							break
						elif imageFile(file) and file.begins_with(loaded.name):
							loaded.cover = "{IMG PATH}"+file
							Loader._save("user://Albums/"+i.album,loaded)
					
					dir.list_dir_end()
					
				if albums.find(loaded.name) == -1:
					albums.append(loaded.name)

func imageFile(file : String):
	return file.ends_with(".png") or file.ends_with(".jpg")

func _on_albums_pressed():
	$Music.visible = false
	$SearchBar.visible = false
	$Albums.visible = true
	$AlbumSong.visible = false

func _on_music_pressed():
	$Albums.visible = false
	$AlbumSong.visible = false
	$Music.visible = true
	$SearchBar.visible = true

func showHome():
	self.visible = true
	_on_music_pressed()

func hideHome():
	self.visible = false

func _on_search_bar_text_changed():
	for i in $Music/SongList.get_children():
		if i is MusicSelection:
			i.visible = !(i.songName.to_lower().find($SearchBar.text) == -1 and not $SearchBar.text == "")
		elif i is Label:
			i.visible = $SearchBar.text == ""
