extends Node
class_name TrackLister

var music : Array[MusicData] = []
var albums : Array[AlbumData] = []
var paths : Array[String] = []

const illegalChars : Array[String] = ["\\","/",":"]

signal ListChanged

func _ready():
	Reload()

##Look for music files in saved directories
func Reload(forceMetaUpdate = false):
	paths = Loader.config.musicPaths
	music = []
	albums = []
	
	for p in paths:
		var files := FindMusicFiles(p)
		
		#Go over files in dir
		for i in files:
			
			var loadedMusic := CheckMusicData(p,i,forceMetaUpdate)
			if music.filter(func(d): return d.name == loadedMusic.name).size() == 0:
				music.append(loadedMusic)
	
	var uniqueAlbums : Array = []
	for i in music:
		if i.album != "":
			if uniqueAlbums.find(i.album) == -1:
				uniqueAlbums.append(i.album)
	
	for i in uniqueAlbums:
		var loadedAlbum := CheckAlbumData(i)
		albums.append(loadedAlbum)
	
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

func CheckMusicData(p : String,i : String,forceMetaUpdate := false) -> MusicData:
	var data := MetaDataReader.GetFromAudioFile(p+"/"+i)
	var path = i
	if data != null:
		if data.Title.is_valid_filename() and data.Title != "":
			path = data.Title
	
	for c in illegalChars:
		path = path.replace(c,'')
	
	var loaded = Loader._load("user://Songs/"+path)
	
	#Create new data if there isn't any
	if loaded == null or forceMetaUpdate:
		var save : MusicData = null
		
		if data != null:
			save = MusicData.Create(path,p+"/"+i,"",data.Album,data.Index)
		else:
			save = MusicData.Create(i,p+"/"+i)
		
		Loader._save("user://Songs/"+save.name,save)
		loaded = save
	
	return loaded

##Load album data or create new data if it doesn't exist.
func CheckAlbumData(albumName : String) -> AlbumData:
	var path := albumName
	for c in illegalChars:
		path = path.replace(c,'')
	
	var loaded = Loader._load("user://Albums/"+path)
	
	if loaded == null:
		var save = AlbumData.Create(albumName) #TODO Artists aren't listed yet
		Loader._save("user://Albums/"+path,save)
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
