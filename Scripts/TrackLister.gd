extends Node
class_name TrackLister

var music : Array[MusicData] = []
var albums : Array[AlbumData] = []
var albumCovers : Array[ImageTexture] = []
var paths : Array[String] = []

#Seems to not work with threading?
#const illegalChars : Array[String] = ["\\","/",":","?","*","\"","|","%","<",">"]

signal ListChanged

func _ready() -> void:
	Reload()

##Used for performance tests.[br]
##Same as [TrackLister.Reload] but also prints the load time and amount into the console.
func MeasureReloadSpeed():
	var time = Time.get_ticks_msec()
	Reload()
	print("Took %f seconds to load" % ((Time.get_ticks_msec() - time) / 1000.0))
	print("While loading: %s total tracks and %s total albums!" % [music.size(),albums.size()] )

##Look for music files in saved directories
func Reload(forceMetaUpdate = false) -> void:
	paths = Loader.config.musicPaths
	music = []
	albums = []
	
	var threads : Array[Thread] = []
	
	for p in paths:
		var newThread := Thread.new()
		newThread.start(AddMusicFromPath.bind(p,forceMetaUpdate))
		threads.append(newThread)
	
	for t in threads:
		var result : Array[MusicData] = t.wait_to_finish()
		for i in result:
			if music.filter(func(d): return d.name == i.name).size() == 0:
				music.append(i)
	
	var uniqueAlbums : Array = []
	for i in music:
		if i.album != "":
			if uniqueAlbums.find(i.album) == -1:
				uniqueAlbums.append(i.album)
	
	for i in uniqueAlbums:
		var loadedAlbum := CheckAlbumData(i)
		albums.append(loadedAlbum)
	albums.sort_custom(func(a,b): return a.name < b.name)
	
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

##Call check music data on every file in the given directory.
##And return all data for the music in the directory.
func AddMusicFromPath(p : String,forceMetaUpdate := false) -> Array[MusicData]:
	var files := FindMusicFiles(p)
	var newMusic : Array[MusicData] = []
	
	#Go over files in dir
	for i in files:
		var loadedMusic := CheckMusicData(p,i,forceMetaUpdate)
		newMusic.append(loadedMusic)
	
	return newMusic

func CheckMusicData(p : String,i : String,forceMetaUpdate := false) -> MusicData:
	var data := MetaDataReader.GetFromAudioFile(p+"/"+i)
	
	#Check wich name should be used for the file name
	var path = i
	if data != null:
		if data.Title.is_valid_filename() and data.Title != "":
			path = data.Title
	
	#Remove unsuported file name characters
	var illegalChars : Array[String] = ["\\","/",":","?","*","\"","|","%","<",">"]
	for c in illegalChars:
		path = path.replace(c,'')
	
	#Load the data
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
	
	#Remove unsuported file name characters
	var illegalChars : Array[String] = ["\\","/",":","?","*","\"","|","%","<",">"]
	for c in illegalChars:
		path = path.replace(c,'')
	
	#Load the data
	var loaded = Loader._load("user://Albums/"+path)
	
	#Create new data if there isn't any
	if loaded == null:
		var save = AlbumData.Create(albumName) #TODO Artists aren't listed yet
		Loader._save("user://Albums/"+path,save)
		loaded = save
	
	return loaded

func LoadAlbumCover(data : AlbumData) -> ImageTexture:
	var list := music.filter(func(d): return d.album == data.name)
	if list.size() <= 0: return null
	
	var cache = albumCovers.filter(func(c): return c.resource_name == data.name)
	if cache.size() > 0:
		return cache.front()
	
	for i in list:
		var result = MetaDataReader.GetImageFromAudioFile(i.path,0) #Causes errors for some JPEG's
		
		if result != null:
			if result is ImageTexture:
				result.resource_name = data.name
				albumCovers.append(result)
				
				return result
	
	return null;

static func MusicFile(file) -> bool:
	return file.ends_with(".wav") or file.ends_with(".mp3") or file.ends_with(".ogg")

static func ImageFile(file : String) -> bool:
	return file.ends_with(".png") or file.ends_with(".jpg")
