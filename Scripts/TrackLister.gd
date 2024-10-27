extends Node
class_name TrackLister

var music : Array[MusicData] = []
var albums : Array[AlbumData] = []
var paths : Array[String] = []



signal ListChanged

func _ready():
	Reload()

##Look for music files in saved directories
func Reload():
	paths = Loader.config.musicPaths
	music = []
	albums = []
	
	for p in paths:
		var files := FindMusicFiles(p)
		
		#Go over files in dir
		for i in files:
			var loaded = Loader._load("user://Songs/"+i)
			
			#Create new data if there isn't any
			if loaded == null:
				var save = MusicData.Create(i,p+"/"+i)
				Loader._save("user://Songs/"+i,save)
				loaded = save
			
			if music.find(loaded) == -1:
				music.append(loaded)
	
	var uniqueAlbums : Array = []
	for i in music:
		if i.album != "":
			if uniqueAlbums.find(i.album) == -1:
				uniqueAlbums.append(i.album)
	
	for i in uniqueAlbums:
		var loaded := CheckAlbumData(i)
		albums.append(loaded)
	
	ListChanged.emit()

func FindMusicFiles(path : String) -> Array:
	var files := []
	var dir := DirAccess.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif MusicFile(file) and not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	return files

##Load album data or create new data if it doesn't exist.
func CheckAlbumData(albumName : String) -> AlbumData:
	var loaded = Loader._load("user://Albums/"+albumName)
	
	if loaded == null:
		var save = AlbumData.Create(albumName) #TODO Artists aren't listed yet
		Loader._save("user://Songs/"+albumName,save)
		loaded = save
	
	#Check for a cover
	if loaded.cover == "":
		var dir = DirAccess.open(Loader.config.coverPath)
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif ImageFile(file) and file.begins_with(loaded.name):
				loaded.cover = Loader.config.coverPath+file
				Loader._save("user://Albums/"+albumName,loaded)
		
		dir.list_dir_end()
	
	return loaded

func MusicFile(file) -> bool:
	return file.ends_with(".wav") or file.ends_with(".mp3") or file.ends_with(".ogg")

func ImageFile(file : String) -> bool:
	return file.ends_with(".png") or file.ends_with(".jpg")
